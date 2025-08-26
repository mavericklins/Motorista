import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scheduled_ride.dart';
import '../../services/scheduled_rides_service.dart';
import '../../constants/app_colors.dart';

class CorridasProgramadasScreen extends StatefulWidget {
  const CorridasProgramadasScreen({Key? key}) : super(key: key);

  @override
  _CorridasProgramadasScreenState createState() => _CorridasProgramadasScreenState();
}

class _CorridasProgramadasScreenState extends State<CorridasProgramadasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Corridas Programadas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ScheduledRidesService>(
        builder: (context, service, child) {
          return Column(
            children: [
              // Filtros de data
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDatePicker(context),
                        icon: Icon(Icons.calendar_today),
                        label: Text('Filtrar por Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddRideDialog(context),
                        icon: Icon(Icons.add),
                        label: Text('Nova Corrida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Lista de corridas programadas
              Expanded(
                child: service.scheduledRides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma corrida programada',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: service.scheduledRides.length,
                        itemBuilder: (context, index) {
                          final ride = service.scheduledRides[index];
                          return _buildRideCard(ride, service);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(ScheduledRide ride, ScheduledRidesService service) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Corrida #${ride.id.substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ride.pickupAddress} → ${ride.destinationAddress}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${ride.scheduledDateTime.day}/${ride.scheduledDateTime.month} às ${ride.scheduledDateTime.hour}:${ride.scheduledDateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  ride.passengerName,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (ride.status == 'agendada')
                  ElevatedButton.icon(
                    onPressed: () => _acceptScheduledRide(ride.id),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceitar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (ride.status == 'aceita')
                  ElevatedButton.icon(
                    onPressed: () => _startScheduledRide(ride.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _cancelScheduledRide(ride.id, 'user_cancel'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'agendada':
        return Colors.blue;
      case 'aceita':
        return Colors.green;
      case 'em_andamento':
        return AppColors.primary;
      case 'concluida':
        return Colors.grey;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    ).then((date) {
      if (date != null) {
        Provider.of<ScheduledRidesService>(context, listen: false)
            .filterByDate(date);
      }
    });
  }

  void _showAddRideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Corrida Programada'),
        content: Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _acceptScheduledRide(String rideId) {
    Provider.of<ScheduledRidesService>(context, listen: false).acceptScheduledRide(rideId);
  }

  void _startScheduledRide(String rideId) {
    Provider.of<ScheduledRidesService>(context, listen: false).startScheduledRide(rideId);
  }

  void _cancelScheduledRide(String rideId, [String reason = 'user_cancel']) {
    Provider.of<ScheduledRidesService>(context, listen: false).cancelScheduledRide(rideId, reason);
  }
}