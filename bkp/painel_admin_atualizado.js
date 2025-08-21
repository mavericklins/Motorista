// Adicionar ao arquivo app.js do painel administrativo

// Função para detectar motoristas online em tempo real
function setupMotoristaOnlineDetection() {
    // Listener para mudanças na coleção de motoristas
    onSnapshot(collection(db, 'motoristas'), (snapshot) => {
        const agora = new Date();
        const limiteOffline = 2 * 60 * 1000; // 2 minutos em milliseconds
        
        const motoristasOnline = [];
        const motoristasOffline = [];
        
        snapshot.docs.forEach(doc => {
            const motorista = { id: doc.id, ...doc.data() };
            
            // Verificar se o motorista está online baseado no último heartbeat
            const ultimoHeartbeat = motorista.ultimo_heartbeat?.toDate();
            const ultimoUpdate = motorista.ultimo_update?.toDate();
            
            const tempoSemHeartbeat = ultimoHeartbeat ? agora - ultimoHeartbeat : Infinity;
            const tempoSemUpdate = ultimoUpdate ? agora - ultimoUpdate : Infinity;
            
            // Considerar online se:
            // 1. Status é 'online' E
            // 2. Último heartbeat foi há menos de 2 minutos OU último update foi há menos de 2 minutos
            const isOnline = motorista.status === 'online' && 
                           (tempoSemHeartbeat < limiteOffline || tempoSemUpdate < limiteOffline);
            
            if (isOnline) {
                motoristasOnline.push(motorista);
            } else {
                motoristasOffline.push(motorista);
            }
        });
        
        // Atualizar dados globais
        allData.motoristas = [...motoristasOnline, ...motoristasOffline];
        
        // Atualizar interface
        updateMotoristaOnlineStatus(motoristasOnline, motoristasOffline);
        updateRealtimeMapData();
        updateDashboard();
        
        console.log(`Motoristas online: ${motoristasOnline.length}, Offline: ${motoristasOffline.length}`);
    });
}

// Atualizar status de motoristas online na interface
function updateMotoristaOnlineStatus(motoristasOnline, motoristasOffline) {
    // Atualizar contador no mapa
    document.getElementById('motoristasOnlineCount').textContent = motoristasOnline.length;
    
    // Atualizar lista de motoristas online no dashboard
    const container = document.getElementById('motoristasOnline');
    if (container) {
        if (motoristasOnline.length === 0) {
            container.innerHTML = '<div class="online-item"><span>Nenhum motorista online</span></div>';
        } else {
            container.innerHTML = motoristasOnline.slice(0, 5).map(motorista => {
                const ultimoUpdate = motorista.ultimo_update?.toDate();
                const tempoOnline = ultimoUpdate ? formatTempoOnline(new Date() - ultimoUpdate) : 'Agora';
                
                return `
                    <div class="online-item">
                        <div class="online-status ${motorista.em_corrida ? 'busy' : 'available'}"></div>
                        <div class="motorista-info">
                            <span class="motorista-nome">${motorista.nome || 'Motorista'}</span>
                            <small class="motorista-status">${motorista.em_corrida ? 'Em corrida' : 'Disponível'} • ${tempoOnline}</small>
                        </div>
                        ${motorista.latitude && motorista.longitude ? 
                            `<button class="btn-locate" onclick="localizarMotorista('${motorista.id}', ${motorista.latitude}, ${motorista.longitude})" title="Localizar no mapa">
                                <i class="fas fa-map-marker-alt"></i>
                            </button>` : ''
                        }
                    </div>
                `;
            }).join('');
        }
    }
    
    // Atualizar tabela de motoristas com status em tempo real
    updateMotoristaTable();
}

// Atualizar tabela de motoristas com indicadores visuais
function updateMotoristaTable() {
    const tbody = document.getElementById('motoristasTableBody');
    
    if (allData.motoristas.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="loading">Nenhum motorista encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = allData.motoristas.map(motorista => {
        const agora = new Date();
        const ultimoUpdate = motorista.ultimo_update?.toDate();
        const tempoOffline = ultimoUpdate ? agora - ultimoUpdate : Infinity;
        const isOnline = motorista.status === 'online' && tempoOffline < 2 * 60 * 1000;
        
        return `
            <tr class="${isOnline ? 'motorista-online' : 'motorista-offline'}">
                <td>
                    <div class="motorista-status-indicator">
                        <div class="status-dot ${isOnline ? 'online' : 'offline'}"></div>
                        ${motorista.nome || 'N/A'}
                    </div>
                </td>
                <td>${motorista.email || 'N/A'}</td>
                <td>${motorista.telefone || 'N/A'}</td>
                <td>${motorista.veiculo || 'N/A'}</td>
                <td>
                    <span class="badge badge-${isOnline ? 'online' : 'offline'}">
                        ${isOnline ? 'Online' : 'Offline'}
                    </span>
                    ${motorista.em_corrida ? '<span class="badge badge-busy">Em Corrida</span>' : ''}
                </td>
                <td>${motorista.avaliacao ? '⭐'.repeat(Math.floor(motorista.avaliacao)) + ` ${motorista.avaliacao}` : 'N/A'}</td>
                <td>${ultimoUpdate ? formatDate(ultimoUpdate) : 'Nunca'}</td>
                <td>
                    <button class="btn-sm btn-primary" onclick="editMotorista('${motorista.id}')">Editar</button>
                    ${isOnline && motorista.latitude && motorista.longitude ? 
                        `<button class="btn-sm btn-success" onclick="localizarMotorista('${motorista.id}', ${motorista.latitude}, ${motorista.longitude})">Localizar</button>` : ''
                    }
                    <button class="btn-sm btn-danger" onclick="deleteMotorista('${motorista.id}')">Excluir</button>
                </td>
            </tr>
        `;
    }).join('');
}

// Localizar motorista no mapa
function localizarMotorista(motoristaId, latitude, longitude) {
    // Ir para a seção do mapa
    showSection('mapa');
    
    // Centralizar mapa na localização do motorista
    if (realtimeMap) {
        realtimeMap.setView([latitude, longitude], 16);
        
        // Destacar o motorista no mapa
        const motorista = allData.motoristas.find(m => m.id === motoristaId);
        if (motorista) {
            // Criar popup especial para o motorista localizado
            const popup = L.popup()
                .setLatLng([latitude, longitude])
                .setContent(`
                    <div style="text-align: center;">
                        <strong>📍 ${motorista.nome}</strong><br>
                        <small>Status: ${motorista.status}</small><br>
                        <small>Veículo: ${motorista.veiculo || 'N/A'}</small><br>
                        <small>Última atualização: ${formatDate(motorista.ultimo_update?.toDate())}</small>
                    </div>
                `)
                .openOn(realtimeMap);
        }
    }
}

// Formatar tempo online
function formatTempoOnline(milliseconds) {
    const segundos = Math.floor(milliseconds / 1000);
    const minutos = Math.floor(segundos / 60);
    const horas = Math.floor(minutos / 60);
    
    if (segundos < 60) {
        return 'Agora';
    } else if (minutos < 60) {
        return `${minutos}m atrás`;
    } else {
        return `${horas}h ${minutos % 60}m atrás`;
    }
}

// Atualizar função de inicialização principal
function initializeMainApp() {
    initializeRealtimeMap();
    initializeMap();
    loadAllData();
    initializeCharts();
    setupRealTimeUpdates();
    setupMotoristaOnlineDetection(); // Adicionar esta linha
    
    // Atualizar mapa a cada 30 segundos
    setInterval(updateRealtimeMapData, 30000);
}

// CSS adicional para indicadores de status
const additionalStyles = `
    .motorista-status-indicator {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .status-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        flex-shrink: 0;
    }
    
    .status-dot.online {
        background: #10B981;
        box-shadow: 0 0 6px rgba(16, 185, 129, 0.6);
    }
    
    .status-dot.offline {
        background: #6B7280;
    }
    
    .motorista-online {
        background-color: rgba(16, 185, 129, 0.05);
    }
    
    .motorista-offline {
        background-color: rgba(107, 114, 128, 0.05);
    }
    
    .online-status.busy {
        background: #F59E0B;
    }
    
    .online-status.available {
        background: #10B981;
    }
    
    .motorista-info {
        display: flex;
        flex-direction: column;
        flex: 1;
    }
    
    .motorista-nome {
        font-weight: 500;
        color: #333;
    }
    
    .motorista-status {
        color: #666;
        font-size: 0.8rem;
    }
    
    .btn-locate {
        background: #3B82F6;
        color: white;
        border: none;
        padding: 4px 8px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.8rem;
    }
    
    .btn-locate:hover {
        background: #2563EB;
    }
    
    .badge-online {
        background: #D1FAE5;
        color: #065F46;
    }
    
    .badge-offline {
        background: #F3F4F6;
        color: #374151;
    }
    
    .badge-busy {
        background: #FEF3C7;
        color: #92400E;
        margin-left: 4px;
    }
`;

// Adicionar estilos ao documento
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);

