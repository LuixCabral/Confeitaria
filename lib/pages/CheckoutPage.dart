import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_confeitaria/models/Products.dart'; // Certifique-se que este caminho está correto
import 'package:app_confeitaria/service/CartProvider.dart'; // Certifique-se que este caminho está correto
import 'package:app_confeitaria/widgets/OrderStatus.dart'; // Certifique-se que este caminho está correto
import 'package:app_confeitaria/localdata/DatabaseHelper.dart'; // Certifique-se que este caminho está correto

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController(); // NOVO: Controller para o bairro
  final _complementController = TextEditingController();
  bool _isCashOnDelivery = true;
  bool _isLoading = false;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _neighborhoodController.dispose(); // NOVO: Dispose do controller do bairro
    _complementController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final db = DatabaseHelper.instance;
    final userData = await db.getUser();
    if (userData.isNotEmpty) {
      if (mounted) {
        setState(() {
          _nameController.text = userData[0]['name'] ?? '';
          _phoneController.text = userData[0]['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _saveOrder(List<CartItem> cartItems) async {
    final db = DatabaseHelper.instance;
    final userData = await db.getUser();
    int userId;

    if (userData.isEmpty || userData[0]['id'] == null) {
      userId = await db.insertUser(_nameController.text, _phoneController.text);
    } else {
      userId = userData[0]['id'];
      await db.updateUser(_nameController.text, _phoneController.text);
    }

    final orderNumber = "SN-${DateTime.now().millisecondsSinceEpoch}";
    final total = cartItems.fold(0.0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });

    // NOTA: Para salvar o endereço completo (incluindo o bairro) no banco de dados,
    // você precisaria modificar o método 'db.insertOrder' em seu DatabaseHelper.dart
    // para aceitar mais parâmetros (ex: uma string de endereço completo).
    // Exemplo de string de endereço completo:
    // String fullAddress = "${_streetController.text}, Nº ${_houseNumberController.text}, Bairro: ${_neighborhoodController.text}, CEP: ${_cepController.text}${_complementController.text.isNotEmpty ? ', Compl: ${_complementController.text}' : ''}";
    // E a chamada seria: await db.insertOrder(userId, orderNumber, total, fullAddress); (se seu método fosse adaptado)

    // Mantendo a chamada original para evitar quebrar sua implementação atual do DatabaseHelper:
    await db.insertOrder(userId, orderNumber, total);
  }

  void _continueStep() async {
    if (_currentStep == 0) {
      if (_personalInfoFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, preencha todos os campos obrigatórios de Informações Pessoais.")),
        );
      }
    } else if (_currentStep == 1) {
      if (_addressFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, preencha todos os campos obrigatórios de Endereço.")),
        );
      }
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 3) {
      setState(() {
        _isLoading = true;
      });

      try {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await _saveOrder(cartProvider.cartItems);
        cartProvider.clearCart();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OrderStatusPage()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao salvar o pedido: $e")),
          );
        }
      }
    }
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Cancelar Pedido"),
          content: const Text("Deseja realmente cancelar o pedido e voltar para a tela anterior?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Não"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Sim"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    double total = cartItems.fold(0.0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
    String formattedTotal = total.toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Compra"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep == 0) {
              _cancelStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _continueStep,
        onStepCancel: _cancelStep,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continuar'),
                  ),
                if (_currentStep == 3 && !_isLoading)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Finalizar Pedido'),
                  ),
                if (_isLoading && _currentStep == 3)
                  const CircularProgressIndicator(),
                if (_currentStep < 3 || (_currentStep == 3 && !_isLoading))
                  const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancelar' : 'Voltar'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text("Informações Pessoais"),
            content: Form(
              key: _personalInfoFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome Completo",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira seu nome";
                      }
                      if (value.trim().split(' ').length < 2) {
                        return "Por favor, insira seu nome completo";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Telefone (WhatsApp)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneMaskFormatter],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu telefone";
                      }
                      final cleanPhone = value.replaceAll(RegExp(r'[()\-\s]'), '');
                      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
                        return "Telefone inválido";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("Endereço de Entrega"),
            content: Form(
              key: _addressFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      labelText: "CEP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_pin),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [_cepMaskFormatter],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu CEP";
                      }
                      final cleanCep = value.replaceAll(RegExp(r'[\-\s]'), '');
                      if (cleanCep.length != 8) {
                        return "CEP inválido (deve conter 8 dígitos)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: "Nome da Rua/Avenida",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.signpost),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira o nome da rua";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _houseNumberController,
                    decoration: const InputDecoration(
                      labelText: "Número",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira o número da casa";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // Espaço antes do novo campo
                  TextFormField( // NOVO CAMPO: Bairro
                    controller: _neighborhoodController,
                    decoration: const InputDecoration(
                      labelText: "Bairro",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.holiday_village_outlined), // Ícone sugestivo para bairro/vizinhança
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Por favor, insira o bairro";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _complementController,
                    decoration: const InputDecoration(
                      labelText: "Complemento (opcional)",
                      hintText: "Ex: Apto, Bloco, Ponto de Referência",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("Pagamento"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Escolha a forma de pagamento:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text("Pagamento na Entrega"),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: _isCashOnDelivery,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCashOnDelivery = value!;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() { _isCashOnDelivery = true; });
                  },
                ),
                ListTile(
                  title: const Text("Outro Método (Indisponível)"),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: _isCashOnDelivery,
                    onChanged: null,
                  ),
                  enabled: false,
                ),
                if (_isCashOnDelivery)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                    child: Text(
                      "Você pagará o pedido em dinheiro ou cartão diretamente ao entregador.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text("Confirmação do Pedido"),
            content: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Revise seu pedido:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text("Nome: ${_nameController.text}", style: const TextStyle(fontSize: 16)),
                Text("Telefone: ${_phoneController.text}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text( // ATUALIZADO: Incluindo o bairro na exibição do endereço
                    "Endereço: ${_streetController.text}, Nº ${_houseNumberController.text}, Bairro: ${_neighborhoodController.text}${_complementController.text.isNotEmpty ? ', ${_complementController.text}' : ''}, CEP: ${_cepController.text}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Pagamento: ${_isCashOnDelivery ? 'Na Entrega' : 'Outro'}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  "Itens do Pedido:",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${item.product.name} (x${item.quantity})", style: const TextStyle(fontSize: 15))),
                          Text("R\$${(item.product.price * item.quantity).toStringAsFixed(2).replaceAll('.', ',')}", style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total do Pedido:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$ $formattedTotal",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }
}