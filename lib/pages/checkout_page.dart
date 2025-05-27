import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_confeitaria/models/products.dart';
import 'package:app_confeitaria/providers/cart_provider.dart';
import 'package:app_confeitaria/service/api_service.dart';
import 'package:app_confeitaria/service/auth_service.dart';

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
  final _neighborhoodController = TextEditingController();
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
    _cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _cepController.removeListener(_onCepChanged);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    try {
      final name = await authService.getUserName();
      final phone = await authService.getUserPhone();
      if (mounted) {
        setState(() {
          _nameController.text = name ?? '';
          _phoneController.text = phone ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do usuário: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _onCepChanged() {
    String cep = _cepController.text.replaceAll(RegExp(r'[\-\s]'), '');
    if (cep.length == 8) {
      _fetchAddress(cep);
    }
  }

  Future<void> _fetchAddress(String cep) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final addressData = await ApiService.fetchAddress(cep);
      if (mounted) {
        setState(() {
          _streetController.text = addressData['logradouro'] ?? '';
          _neighborhoodController.text = addressData['bairro'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _sendOrderToApi(List<CartItem> cartItems, double total) async {
    final String fullAddress =
        "${_streetController.text}, Nº ${_houseNumberController.text}, Bairro: ${_neighborhoodController.text}, CEP: ${_cepController.text}${_complementController.text.isNotEmpty ? ', Compl: ${_complementController.text}' : ''}";
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final offsetSign = offset.isNegative ? '-' : '+';
    final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final formattedDate =
        "${now.toIso8601String().split('.').first}.${now.millisecond.toString().padLeft(3, '0')}$offsetSign$offsetHours:$offsetMinutes";

    final Map<String, dynamic> orderData = {
      'dateTime': formattedDate,
      'items': cartItems.map((item) => {'id': item.product.id, 'quantity': item.quantity}).toList(),
      'userCode': "1234",
      'address': fullAddress,
      'paymentMethod': _isCashOnDelivery ? 1 : 0,
    };

    try {
      final response = await ApiService.createOrder(orderData);
      if (mounted) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.clearCart();
        return response;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar o pedido: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      rethrow;
    }
    return {};
  }

  Future<void> _saveOrder(List<CartItem> cartItems) async {
    final total = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final response = await _sendOrderToApi(cartItems, total);

    if (mounted) {
      Navigator.pop(context, {
        'name': response['name'] ?? _nameController.text,
        'orderCode': response['orderCode']?.toString() ?? 'Sem código',
        'orderStatus': response['orderStatus']?.toString() ?? 'preparing',
        'orderDate': response['orderDate']?.toString() ?? DateTime.now().toIso8601String(),
        'products': List<Map<String, dynamic>>.from(response['products'] ?? []),
        'totalPrice': (response['totalPrice'] as num?)?.toDouble() ?? total,
        'address': response['address']?.toString() ??
            "${_streetController.text}, Nº ${_houseNumberController.text}, Bairro: ${_neighborhoodController.text}, CEP: ${_cepController.text}${_complementController.text.isNotEmpty ? ', Compl: ${_complementController.text}' : ''}",
      });
    }
  }

  void _continueStep() async {
    if (_currentStep == 0) {
      if (_personalInfoFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Preencha todos os campos obrigatórios de Informações Pessoais."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else if (_currentStep == 1) {
      if (_addressFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Preencha todos os campos obrigatórios de Endereço."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Cancelar Pedido',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: const Text('Deseja realmente cancelar o pedido e voltar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Não', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Sim', style: TextStyle(color: Colors.pink)),
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
    final total = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final formattedTotal = total.toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      backgroundColor: Colors.grey[100], // Matches MainPage
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'Finalizar Compra',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _cancelStep,
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.pink, // Stepper active color
            secondary: Colors.pink, // Stepper completed color
          ),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _continueStep,
          onStepCancel: _cancelStep,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  if (_currentStep < 3)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pink, Colors.pinkAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep == 3 && !_isLoading)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pink, Colors.pinkAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: const Text(
                            'Finalizar Pedido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_isLoading && _currentStep == 3)
                    const CircularProgressIndicator(color: Colors.pink),
                  if (_currentStep < 3 || (_currentStep == 3 && !_isLoading)) ...[
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: details.onStepCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        _currentStep == 0 ? 'Cancelar' : 'Voltar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text(
                'Informações Pessoais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _personalInfoFormKey,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.person, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira seu nome';
                            }
                            if (value.trim().split(' ').length < 2) {
                              return 'Insira o nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefone (WhatsApp)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.phone, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMaskFormatter],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira seu telefone';
                            }
                            final cleanPhone = value.replaceAll(RegExp(r'[()\-\s]'), '');
                            if (cleanPhone.length < 10 || cleanPhone.length > 11) {
                              return 'Telefone inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text(
                'Endereço de Entrega',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _addressFormKey,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cepController,
                          decoration: InputDecoration(
                            labelText: 'CEP',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.location_pin, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                            suffixIcon: _isLoading ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ) : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_cepMaskFormatter],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira seu CEP';
                            }
                            final cleanCep = value.replaceAll(RegExp(r'[\-\s]'), '');
                            if (cleanCep.length != 8) {
                              return 'CEP inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _streetController,
                          decoration: InputDecoration(
                            labelText: 'Rua/Avenida',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.signpost, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira o nome da rua';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _houseNumberController,
                          decoration: InputDecoration(
                            labelText: 'Número',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.numbers, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira o número';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _neighborhoodController,
                          decoration: InputDecoration(
                            labelText: 'Bairro',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.holiday_village_outlined, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira o bairro';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _complementController,
                          decoration: InputDecoration(
                            labelText: 'Complemento (opcional)',
                            hintText: 'Ex: Apto, Bloco',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.info_outline, color: Colors.pink),
                            labelStyle: const TextStyle(color: Colors.grey),
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text(
                'Pagamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forma de Pagamento',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _isCashOnDelivery,
                        onChanged: (value) {
                          setState(() {
                            _isCashOnDelivery = value!;
                          });
                        },
                        title: const Text('Pagamento na Entrega', style: TextStyle(color: Colors.black87)),
                        activeColor: Colors.pink,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        tileColor: _isCashOnDelivery ? Colors.pink[50] : null,
                      ),
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _isCashOnDelivery,
                        onChanged: null,
                        title: const Text('Outro Método (Indisponível)', style: TextStyle(color: Colors.grey)),
                        activeColor: Colors.pink,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        tileColor: Colors.grey[200],
                      ),
                      if (_isCashOnDelivery)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: Text(
                            'Pague em dinheiro ou cartão diretamente ao entregador.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text(
                'Confirmação do Pedido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                  : Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revise seu pedido:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryItem('Nome', _nameController.text),
                      _buildSummaryItem('Telefone', _phoneController.text),
                      _buildSummaryItem(
                        'Endereço',
                        '${_streetController.text}, Nº ${_houseNumberController.text}, ${_neighborhoodController.text}${_complementController.text.isNotEmpty ? ', ${_complementController.text}' : ''}, CEP: ${_cepController.text}',
                      ),
                      _buildSummaryItem('Pagamento', _isCashOnDelivery ? 'Na Entrega' : 'Outro'),
                      const Divider(height: 32),
                      const Text(
                        'Itens do Pedido:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} (x${item.quantity})',
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                ),
                                Text(
                                  'R\$${(item.product.price * item.quantity).toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.pink),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total do Pedido:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            'R\$$formattedTotal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}