import 'package:app_plaza_flutter/models/payment_details.dart';
import 'package:app_plaza_flutter/router/app_router.dart';
import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_plaza_flutter/controllers/account_controller.dart'; // Ajusta la ruta a tu controlador

class PreOrderAccountView extends ConsumerWidget {
  const PreOrderAccountView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del recibo (AccountReceipt)
    final accountReceipt = ref.watch(accountControllerProvider);
    final accountNotifier = ref.read(accountControllerProvider.notifier);
    final router = ref.read(appRouterProvider);

    // Escuchamos de forma reactiva las variables de UI mutadas dentro del controlador
    ref.listen(accountControllerProvider, (previous, next) {
      if (accountNotifier.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cuenta cerrada y mesas desocupadas correctamente."),
          ),
        );
        router.pop(); // Retorna al flujo principal
      }
      if (accountNotifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accountNotifier.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    if (accountNotifier.currentOrder == null) {
      return const Scaffold(
        body: Center(
          child: Text("No se ha seleccionado ninguna orden activa."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.quaternaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => router.pop(),
        ),
        title: const Text(
          "Pre-Cuenta de Mesa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Panel Financiero (Datos obtenidos del estado AccountReceipt)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildAmountRow(
                      "Consumo Total",
                      "S/. ${accountReceipt.total.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                    const Divider(height: 20),
                    _buildAmountRow(
                      "Subtotal (Base Imponible)",
                      "S/. ${accountReceipt.subtotal.toStringAsFixed(2)}",
                    ),
                    const SizedBox(height: 6),
                    _buildAmountRow(
                      "IGV Asumido (10.5%)",
                      "S/. ${accountReceipt.igv.toStringAsFixed(2)}",
                      color: Colors.grey[600],
                    ),
                    const Divider(height: 20),
                    _buildAmountRow(
                      "Total a Pagar",
                      "S/. ${accountReceipt.total.toStringAsFixed(2)}",
                      isBold: true,
                      textColor: AppTheme.primaryColor,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),

              // Encabezado de Control de Caja
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MÉTODOS DE PAGO REGISTRADOS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      accountNotifier.isAccountSettled
                          ? "CUENTA CUBIERTA"
                          : "FALTAN: S/. ${accountNotifier.pendingAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accountNotifier.isAccountSettled
                            ? Colors.green[700]
                            : Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Listado Dinámico de Pagos Parciales
              Expanded(
                child: accountReceipt.payments.isEmpty
                    ? Center(
                        child: Text(
                          "No hay pagos registrados para esta mesa.",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: accountReceipt.payments.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = accountReceipt.payments[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  _getIconForMethod(item.method),
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                item.method,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: item.reference != null
                                  ? Text("Ref: ${item.reference}")
                                  : Text(
                                      "Entregado: S/. ${item.received?.toStringAsFixed(2)} | Vuelto: S/. ${item.change?.toStringAsFixed(2)}",
                                    ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "S/. ${item.amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        accountNotifier.removePaymentAt(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Panel de Control de Acciones Inferiores
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!accountNotifier.isAccountSettled)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _showMethodSelectionGrid(
                              context,
                              accountNotifier.pendingAmount,
                              accountNotifier,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_card_rounded,
                              color: AppTheme.primaryColor,
                            ),
                            label: const Text(
                              "Agregar Pago Parcial",
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      if (accountNotifier.isAccountSettled)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                accountNotifier.submitAndCloseAccount(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "CONCLUIR Y EMITIR COMPROBANTE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bloqueador de pantalla táctil durante la sincronización transaccional
          if (accountNotifier.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
    double fontSize = 14,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.grey[800],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Obtener ícono a través del método de pago.
  IconData _getIconForMethod(String method) {
    switch (method) {
      case 'Yape':
        return Icons.phone_android_rounded;
      case 'Plin':
        return Icons.pix_rounded;
      case 'Tarjeta':
        return Icons.credit_card_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  void _showMethodSelectionGrid(
    BuildContext context,
    double pendingAmount,
    AccountController accountNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final List<Map<String, dynamic>> options = [
          {
            'name': 'Yape',
            'icon': Icons.phone_android_rounded,
            'color': Colors.purple[700],
          },
          {
            'name': 'Plin',
            'icon': Icons.pix_rounded,
            'color': Colors.teal[600],
          },
          {
            'name': 'Efectivo',
            'icon': Icons.payments_rounded,
            'color': Colors.green[700],
          },
          {
            'name': 'Tarjeta',
            'icon': Icons.credit_card_rounded,
            'color': Colors.blue[800],
          },
        ];

        return AlertDialog(
          title: const Text(
            "Seleccione Método",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 275,
            height: 180,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final current = options[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPaymentDataForm(
                      context,
                      current['name'],
                      pendingAmount,
                      accountNotifier,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: current['color']!.withValues(alpha: 0.1),
                      border: Border.all(color: current['color']!, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          current['icon'],
                          size: 36,
                          color: current['color'],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: current['color'],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDataForm(
    BuildContext context,
    String method,
    double pendingAmount,
    AccountController accountNotifier,
  ) {
    final amountController = TextEditingController(
      text: pendingAmount.toStringAsFixed(2),
    );
    final extraInputController = TextEditingController();
    final changeNotifier = ValueNotifier<double>(0.0);
    final isCash = method == 'Efectivo';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        void recalculateChange() {
          final amt = double.tryParse(amountController.text) ?? 0.0;
          debugPrint("[RECALCULATE CHANGE] Monto dado: $amt.");
          final rec = double.tryParse(extraInputController.text) ?? 0.0;
          debugPrint("[RECALCULATE CHANGE] Vuelto: $rec.");
          changeNotifier.value = (rec - amt) < 0 ? 0.0 : (rec - amt);
          debugPrint(
            "[RECALCULATE CHANGE] Vuelto Calculado: ${changeNotifier.value}.",
          );
        }

        return AlertDialog(
          title: Text(
            "Detalle de Pago: $method",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Monto Neto a Cubrir (S/.)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (isCash) recalculateChange();
                  },
                ),
                const SizedBox(height: 16),
                if (!isCash) ...[
                  TextField(
                    controller: extraInputController,
                    decoration: const InputDecoration(
                      labelText: "Código de Referencia / Operación",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: extraInputController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Efectivo Entregado (S/.)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => recalculateChange(),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: changeNotifier,
                    builder: (context, changeValue, _) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Vuelto Sugerido:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "S/. ${changeValue.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final finalAmount =
                    double.tryParse(amountController.text) ?? 0.0;
                if (finalAmount <= 0) return;

                if (isCash) {
                  final received =
                      double.tryParse(extraInputController.text) ?? finalAmount;
                  accountNotifier.addPayment(
                    PaymentDetails(
                      method: method,
                      amount: finalAmount,
                      received: received,
                      change: (received - finalAmount) < 0
                          ? 0.0
                          : (received - finalAmount),
                    ),
                  );
                } else {
                  final refCode = extraInputController.text.trim();
                  accountNotifier.addPayment(
                    PaymentDetails(
                      method: method,
                      amount: finalAmount,
                      reference: refCode.isEmpty ? 'Sin Referencia' : refCode,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
