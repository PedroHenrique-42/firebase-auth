import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_second/features/products/services/product_service.dart';
import 'package:flutter_firebase_firestore_second/features/products/utils/enum_order.dart';
import 'package:uuid/uuid.dart';

import '../../../listins/models/listin.dart';
import '../../models/produto.dart';
import '../widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;

  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  List<Produto> _listaProdutosPlanejados = [];
  List<Produto> _listaProdutosPegos = [];

  ProductService productService = ProductService();

  OrdenacaoProdutos _ordenacaoProdutos = OrdenacaoProdutos.name;
  bool _isDecrescente = false;

  late StreamSubscription _firestoreListener;

  @override
  void initState() {
    super.initState();
    setupListeners();
  }

  @override
  void dispose() {
    _firestoreListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            tooltip: "Ordenação da lista",
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: OrdenacaoProdutos.name,
                child: Text("Ordenar por nome"),
              ),
              const PopupMenuItem(
                value: OrdenacaoProdutos.amount,
                child: Text("Ordenar por quantidade"),
              ),
              const PopupMenuItem(
                value: OrdenacaoProdutos.price,
                child: Text("Ordenar por preço"),
              ),
            ],
            onSelected: (OrdenacaoProdutos ordenacaoProdutosEscolhida) {
              setState(() {
                if (_ordenacaoProdutos == ordenacaoProdutosEscolhida) {
                  _isDecrescente = !_isDecrescente;
                }

                if (_ordenacaoProdutos != ordenacaoProdutosEscolhida) {
                  _ordenacaoProdutos = ordenacaoProdutosEscolhida;
                  _isDecrescente = false;
                }
              });
              refresh();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => refresh(),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "R\$${calcularPrecoPegos().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(_listaProdutosPlanejados.length, (index) {
                Produto produto = _listaProdutosPlanejados[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: false,
                  iconClick: alternarComprado,
                  trailClick: removerProduto,
                  showModal: showFormModal,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(_listaProdutosPegos.length, (index) {
                Produto produto = _listaProdutosPegos[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: true,
                  iconClick: alternarComprado,
                  trailClick: removerProduto,
                  showModal: showFormModal,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  setupListeners() {
    _firestoreListener = ProductService().connectStream(
      listinId: widget.listin.id,
      productsOrdenation: _ordenacaoProdutos,
      descending: _isDecrescente,
      onChange: refresh,
    );
  }

  Future<void> refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> products = await productService.readProducts(
      listinId: widget.listin.id,
      productsOrdenation: _ordenacaoProdutos,
      descending: _isDecrescente,
      snapshot: snapshot,
    );

    if (snapshot != null && snapshot.docChanges.isNotEmpty) {
      showSnapshotChangeIndicator(snapshot);
    }

    filtrarProdutos(products);
  }

  void showSnapshotChangeIndicator(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    DocumentChange<Map<String, dynamic>> snapshotChange =
        snapshot.docChanges.first;
    bool theresOnlyOneChange = snapshot.docChanges.length == 1;

    if (theresOnlyOneChange) {
      String productChangedName = snapshotChange.doc.data()?["name"];
      Color color = defineSnackBarColorBasedOnChangeType(
        snapshotChange.type,
      );

      showSnackBar(title: productChangedName, backgroundColor: color);
    }
  }

  Color defineSnackBarColorBasedOnChangeType(DocumentChangeType changeType) {
    if (changeType == DocumentChangeType.added) {
      return Colors.green;
    }
    if (changeType == DocumentChangeType.removed) {
      return Colors.red;
    }
    return Colors.orange;
  }

  void showSnackBar({required String title, required Color backgroundColor}) {
    ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(
      context,
    );
    scaffoldMessengerState.removeCurrentSnackBar();
    scaffoldMessengerState.showSnackBar(
      SnackBar(backgroundColor: backgroundColor, content: Text(title)),
    );
  }

  void showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(
                labelTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        produto.id = model.id;
                      }

                      if (amountController.text != "") {
                        produto.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        produto.price = double.parse(priceController.text);
                      }

                      // Salvar no Firestore
                      ProductService().addProduct(
                        listinId: widget.listin.id,
                        product: produto,
                      );

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void filtrarProdutos(List<Produto> listaProdutos) {
    List<Produto> tempPlanejados = [];
    List<Produto> tempPegos = [];

    for (var produto in listaProdutos) {
      if (!produto.isComprado) {
        tempPlanejados.add(produto);
      }
      if (produto.isComprado) {
        tempPegos.add(produto);
      }
    }

    setState(() {
      _listaProdutosPlanejados = tempPlanejados;
      _listaProdutosPegos = tempPegos;
    });
  }

  void alternarComprado(Produto produto) async {
    await productService.updateProduct(
      listinId: widget.listin.id,
      product: produto,
    );
  }

  void removerProduto(Produto produto) async {
    await productService.removeProduct(
      listinId: widget.listin.id,
      product: produto,
    );
  }

  double calcularPrecoPegos() {
    double total = 0;

    for (Produto produto in _listaProdutosPegos) {
      if (produto.amount != null && produto.price != null) {
        total += (produto.amount! * produto.price!);
      }
    }
    return total;
  }
}
