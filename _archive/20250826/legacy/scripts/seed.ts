import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

admin.initializeApp();
const db = admin.firestore();

async function main() {
  const agora = Timestamp.now();

  // usuarios básicos
  const uPass = db.collection('usuarios').doc('pass_demo');
  const uMot = db.collection('usuarios').doc('mot_demo');
  await uPass.set({ nome: 'Passageiro Demo', tipo: 'passageiro', status: 'ativo', criadoEm: agora, atualizadoEm: agora });
  await uMot.set({ nome: 'Motorista Demo', tipo: 'motorista', status: 'ativo', criadoEm: agora, atualizadoEm: agora });

  await db.collection('passageiros').doc('pass_demo').set({ totalCorridas: 0, totalGasto: 0, criadoEm: agora, atualizadoEm: agora });
  await db.collection('motoristas').doc('mot_demo').set({
    status: 'online',
    ativo: true,
    verificado: true,
    localizacaoAtual: { geohash: '6gkzw', ponto: new admin.firestore.GeoPoint(-23.56, -46.63), latitude: -23.56, longitude: -46.63 },
    criadoEm: agora,
    atualizadoEm: agora
  });

  // corrida
  const corridaRef = db.collection('corridas').doc();
  await corridaRef.set({
    passageiroId: 'pass_demo', passageiroNome: 'Passageiro Demo', passageiroTelefone: '+55...',
    origem: { endereco: 'Av. Paulista, 1000', latitude: -23.56, longitude: -46.65 },
    destino: { endereco: 'Rua Vergueiro, 100', latitude: -23.59, longitude: -46.62 },
    valor: 22.50, valorMotorista: 18.00, taxaPlataforma: 4.50,
    formaPagamento: 'pix', status: 'pendente',
    dataHoraSolicitacao: agora, criadoEm: agora, atualizadoEm: agora,
    distanciaEstimada: 6.3, tempoEstimado: 18
  });

  console.log('Seed OK');
  process.exit(0);
}

main().catch(err => { console.error(err); process.exit(1); });
