// Variáveis globais
let map;
let realtimeMap;
let currentUser = null;
let allData = {
    motoristas: [],
    corridas: [],
    passageiros: []
};
let charts = {};
let mapMarkers = [];
let realtimeMarkers = [];

// Inicialização
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Auth state listener
    onAuthStateChanged(auth, (user) => {
        if (user) {
            currentUser = user;
            showMainApp();
            initializeMainApp();
        } else {
            currentUser = null;
            showLogin();
        }
    });
}

function showLogin() {
    document.getElementById('loginContainer').style.display = 'flex';
    document.getElementById('mainContainer').style.display = 'none';
}

function showMainApp() {
    document.getElementById('loginContainer').style.display = 'none';
    document.getElementById('mainContainer').style.display = 'block';
}

function initializeMainApp() {
    initializeRealtimeMap();
    // initializeMap(); // Desabilitado - usando apenas mapa em tempo real
    loadAllData();
    initializeCharts();
    setupRealTimeUpdates();
    
    // Atualizar mapa a cada 30 segundos
    setInterval(updateRealtimeMapData, 30000);
}

// Mapa em Tempo Real
function initializeRealtimeMap() {
    realtimeMap = L.map('realtimeMap').setView([-23.5505, -46.6333], 11);
    
    L.tileLayer('https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae', {
        attribution: '&copy; <a href="https://www.geoapify.com/">Geoapify</a> | &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(realtimeMap);
    
    // Marcador São Paulo
    L.marker([-23.5505, -46.6333])
        .addTo(realtimeMap)
        .bindPopup('<strong>São Paulo</strong><br>Centro de Operações Vello');
}

function updateRealtimeMapData() {
    // Limpar marcadores existentes
    realtimeMarkers.forEach(marker => realtimeMap.removeLayer(marker));
    realtimeMarkers = [];
    
    const filter = document.getElementById('mapFilterInline').value;
    
    // Adicionar motoristas online
    if (filter === 'all' || filter === 'motoristas') {
        const motoristasOnline = allData.motoristas.filter(m => m.status === 'ativo' || m.status === 'online');
        
        motoristasOnline.forEach(motorista => {
            // Gerar coordenadas aleatórias próximas a São Paulo se não existirem
            const lat = motorista.latitude || (-23.5505 + (Math.random() - 0.5) * 0.1);
            const lng = motorista.longitude || (-46.6333 + (Math.random() - 0.5) * 0.1);
            
            const marker = L.marker([lat, lng], {
                icon: L.divIcon({
                    html: '<i class="fas fa-car" style="color: #007bff; font-size: 16px;"></i>',
                    iconSize: [20, 20],
                    className: 'custom-div-icon'
                })
            }).addTo(realtimeMap);
            
            marker.bindPopup(`
                <div style="text-align: center;">
                    <strong>${motorista.nome || 'Motorista'}</strong><br>
                    <small>Status: ${motorista.status || 'Online'}</small><br>
                    <small>Veículo: ${motorista.veiculo || 'N/A'}</small><br>
                    <small>Avaliação: ${'⭐'.repeat(Math.floor(motorista.avaliacao || 4.5))}</small><br>
                    <button onclick="locateMotorista('${motorista.id}')" style="background: #007bff; color: white; border: none; padding: 5px 10px; border-radius: 3px; margin-top: 5px; cursor: pointer;">
                        <i class="fas fa-map-marker-alt"></i> Centralizar
                    </button>
                </div>
            `);
            
            realtimeMarkers.push(marker);
        });
        
        document.getElementById('motoristasOnlineCount').textContent = motoristasOnline.length;
    }
    
    // Adicionar corridas ativas
    if (filter === 'all' || filter === 'corridas') {
        const corridasAtivas = allData.corridas.filter(c => c.status === 'em_andamento' || c.status === 'aceita');
        
        corridasAtivas.forEach(corrida => {
            // Gerar coordenadas aleatórias se não existirem
            const lat = corrida.origem_lat || (-23.5505 + (Math.random() - 0.5) * 0.1);
            const lng = corrida.origem_lng || (-46.6333 + (Math.random() - 0.5) * 0.1);
            
            const marker = L.marker([lat, lng], {
                icon: L.divIcon({
                    html: '<i class="fas fa-route" style="color: #28a745; font-size: 16px;"></i>',
                    iconSize: [20, 20],
                    className: 'custom-div-icon'
                })
            }).addTo(realtimeMap);
            
            marker.bindPopup(`
                <div style="text-align: center;">
                    <strong>Corrida Ativa</strong><br>
                    <small>De: ${corrida.origem || 'Origem'}</small><br>
                    <small>Para: ${corrida.destino || 'Destino'}</small><br>
                    <small>Valor: R$ ${corrida.valor || '0,00'}</small>
                </div>
            `);
            
            realtimeMarkers.push(marker);
        });
        
        document.getElementById('corridasAtivasCount').textContent = corridasAtivas.length;
    }
    
    // Simular passageiros aguardando
    const passageirosAguardando = Math.floor(Math.random() * 5) + 1;
    document.getElementById('passageirosAguardandoCount').textContent = passageirosAguardando;
}

function updateMapFilter() {
    updateRealtimeMapData();
}

function refreshRealtimeMap() {
    if (realtimeMap) {
        realtimeMap.invalidateSize();
        updateRealtimeMapData();
        
        // Animação de refresh
        const btn = document.querySelector('.btn-refresh i');
        btn.style.animation = 'spin 1s linear';
        setTimeout(() => btn.style.animation = '', 1000);
    }
}

// Geolocalização
let userLocationMarker = null;

function goToMyLocation() {
    const btn = document.querySelector('.btn-location');
    const icon = btn.querySelector('i');
    
    // Verificar se o navegador suporta geolocalização
    if (!navigator.geolocation) {
        alert('Geolocalização não é suportada pelo seu navegador');
        return;
    }
    
    // Adicionar estado de loading
    btn.classList.add('loading');
    icon.className = 'fas fa-spinner';
    
    // Opções de geolocalização
    const options = {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 60000
    };
    
    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            const accuracy = position.coords.accuracy;
            
            console.log('Localização encontrada:', { lat, lng, accuracy });
            
            // Centralizar mapa na localização do usuário
            realtimeMap.setView([lat, lng], 15);
            
            // Remover marcador anterior se existir
            if (userLocationMarker) {
                realtimeMap.removeLayer(userLocationMarker);
            }
            
            // Adicionar marcador da localização do usuário
            userLocationMarker = L.marker([lat, lng], {
                icon: L.divIcon({
                    html: '<i class="fas fa-user-circle" style="color: #ff6b35; font-size: 20px;"></i>',
                    iconSize: [25, 25],
                    className: 'custom-div-icon user-location'
                })
            }).addTo(realtimeMap);
            
            userLocationMarker.bindPopup(`
                <div style="text-align: center;">
                    <strong>📍 Sua Localização</strong><br>
                    <small>Lat: ${lat.toFixed(6)}</small><br>
                    <small>Lng: ${lng.toFixed(6)}</small><br>
                    <small>Precisão: ${Math.round(accuracy)}m</small>
                </div>
            `).openPopup();
            
            // Adicionar círculo de precisão
            L.circle([lat, lng], {
                radius: accuracy,
                color: '#ff6b35',
                fillColor: '#ff6b35',
                fillOpacity: 0.1,
                weight: 2
            }).addTo(realtimeMap);
            
            // Remover estado de loading
            btn.classList.remove('loading');
            icon.className = 'fas fa-crosshairs';
            
        },
        function(error) {
            console.error('Erro de geolocalização:', error);
            
            let errorMessage = 'Erro ao obter localização';
            
            switch(error.code) {
                case error.PERMISSION_DENIED:
                    errorMessage = 'Permissão de localização negada. Permita o acesso à localização nas configurações do navegador.';
                    break;
                case error.POSITION_UNAVAILABLE:
                    errorMessage = 'Localização indisponível. Verifique se o GPS está ativado.';
                    break;
                case error.TIMEOUT:
                    errorMessage = 'Tempo limite excedido. Tente novamente.';
                    break;
            }
            
            alert(errorMessage);
            
            // Remover estado de loading
            btn.classList.remove('loading');
            icon.className = 'fas fa-crosshairs';
        },
        options
    );
}

// Função para calcular distância entre dois pontos
function calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Raio da Terra em km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng/2) * Math.sin(dLng/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}

// Autenticação
async function handleLogin(event) {
    event.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    
    try {
        await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
        alert('Erro no login: ' + error.message);
    }
}

async function handleLogout() {
    try {
        await signOut(auth);
    } catch (error) {
        alert('Erro no logout: ' + error.message);
    }
}

// Navegação
function showSection(sectionName) {
    // Remove active de todos os nav-items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // Remove active de todas as sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Adiciona active ao nav-item clicado
    event.target.closest('.nav-item').classList.add('active');
    
    // Adiciona active à section correspondente
    document.getElementById(sectionName).classList.add('active');
    
    // Atualiza título da página
    const titles = {
        'dashboard': 'Dashboard',
        'mapa': 'Mapa',
        'motoristas': 'Motoristas',
        'corridas': 'Corridas',
        'passageiros': 'Passageiros',
        'financeiro': 'Financeiro',
        'relatorios': 'Relatórios',
        'configuracoes': 'Configurações'
    };
    
    document.getElementById('pageTitle').textContent = titles[sectionName] || 'Dashboard';
    
    // Ações específicas por seção
    if (sectionName === 'mapa' && map) {
        setTimeout(() => map.invalidateSize(), 100);
    }
}

function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('open');
}

// Mapa
// Função do segundo mapa desabilitada - usando apenas o mapa em tempo real
/*
function initializeMap() {
    map = L.map('mapContainer').setView([-23.5505, -46.6333], 11);
    
    L.tileLayer('https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae', {
        attribution: '&copy; <a href="https://www.geoapify.com/">Geoapify</a> | &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    
    // Marcador São Paulo
    L.marker([-23.5505, -46.6333])
        .addTo(map)
        .bindPopup('<strong>São Paulo</strong><br>Centro de Operações');
}
*/

function refreshMap() {
    if (map) {
        map.invalidateSize();
        updateMapMarkers();
    }
}

function updateMapMarkers() {
    // Limpar marcadores existentes (exceto São Paulo)
    map.eachLayer(function(layer) {
        if (layer instanceof L.Marker && layer.getLatLng().lat !== -23.5505) {
            map.removeLayer(layer);
        }
    });
    
    // Adicionar marcadores de motoristas
    allData.motoristas.forEach(motorista => {
        if (motorista.latitude && motorista.longitude) {
            const icon = L.divIcon({
                html: '<i class="fas fa-car" style="color: #007bff;"></i>',
                iconSize: [20, 20],
                className: 'custom-div-icon'
            });
            
            L.marker([motorista.latitude, motorista.longitude], { icon })
                .addTo(map)
                .bindPopup(`
                    <strong>${motorista.nome || 'Motorista'}</strong><br>
                    Status: ${motorista.status || 'Ativo'}<br>
                    Veículo: ${motorista.veiculo || 'N/A'}
                `);
        }
    });
    
    // Adicionar marcadores de corridas ativas
    const corridasAtivas = allData.corridas.filter(c => c.status === 'em_andamento');
    corridasAtivas.forEach(corrida => {
        if (corrida.origem_lat && corrida.origem_lng) {
            const icon = L.divIcon({
                html: '<i class="fas fa-route" style="color: #28a745;"></i>',
                iconSize: [20, 20],
                className: 'custom-div-icon'
            });
            
            L.marker([corrida.origem_lat, corrida.origem_lng], { icon })
                .addTo(map)
                .bindPopup(`
                    <strong>Corrida Ativa</strong><br>
                    Origem: ${corrida.origem || 'N/A'}<br>
                    Destino: ${corrida.destino || 'N/A'}
                `);
        }
    });
}

// Carregamento de dados
async function loadAllData() {
    try {
        console.log('Carregando dados do Firebase...');
        
        // Carregar dados do Firebase com tratamento de erro
        const [motoristasSnapshot, corridasSnapshot, passageirosSnapshot] = await Promise.all([
            getDocs(collection(db, 'motoristas')).catch(() => ({ docs: [] })),
            getDocs(collection(db, 'corridas')).catch(() => ({ docs: [] })),
            getDocs(collection(db, 'passageiros')).catch(() => ({ docs: [] }))
        ]);
        
        allData.motoristas = motoristasSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        allData.corridas = corridasSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        allData.passageiros = passageirosSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        
        console.log('Dados carregados:', {
            motoristas: allData.motoristas.length,
            corridas: allData.corridas.length,
            passageiros: allData.passageiros.length
        });
        
        // Se não há dados reais, usar dados de exemplo
        if (allData.motoristas.length === 0 && allData.corridas.length === 0 && allData.passageiros.length === 0) {
            console.log('Nenhum dado encontrado, carregando dados de exemplo...');
            loadSampleData();
        }
        
        // Atualizar interface
        updateAllInterfaces();
        
    } catch (error) {
        console.error('Erro ao carregar dados:', error);
        loadSampleData();
    }
}

function loadSampleData() {
    // Dados de exemplo mais realistas
    allData = {
        motoristas: [
            {
                id: '1',
                nome: 'João Silva',
                email: 'joao.silva@email.com',
                telefone: '(11) 99999-1111',
                veiculo: 'Honda Civic 2020 - Prata',
                status: 'ativo',
                avaliacao: 4.8,
                latitude: -23.5505 + (Math.random() - 0.5) * 0.05,
                longitude: -46.6333 + (Math.random() - 0.5) * 0.05,
                data_cadastro: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
            },
            {
                id: '2',
                nome: 'Maria Santos',
                email: 'maria.santos@email.com',
                telefone: '(11) 88888-2222',
                veiculo: 'Toyota Corolla 2021 - Branco',
                status: 'ativo',
                avaliacao: 4.9,
                latitude: -23.5505 + (Math.random() - 0.5) * 0.05,
                longitude: -46.6333 + (Math.random() - 0.5) * 0.05,
                data_cadastro: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString()
            },
            {
                id: '3',
                nome: 'Carlos Oliveira',
                email: 'carlos.oliveira@email.com',
                telefone: '(11) 77777-3333',
                veiculo: 'Hyundai HB20 2019 - Azul',
                status: 'inativo',
                avaliacao: 4.6,
                data_cadastro: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000).toISOString()
            },
            {
                id: '4',
                nome: 'Ana Costa',
                email: 'ana.costa@email.com',
                telefone: '(11) 66666-4444',
                veiculo: 'Volkswagen Polo 2020 - Vermelho',
                status: 'pendente',
                avaliacao: 0,
                data_cadastro: new Date().toISOString()
            }
        ],
        corridas: [
            {
                id: '1',
                origem: 'Centro, São Paulo - SP',
                destino: 'Vila Madalena, São Paulo - SP',
                passageiro_nome: 'Pedro Almeida',
                motorista_nome: 'João Silva',
                status: 'concluida',
                valor: 25.50,
                data_criacao: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
                origem_lat: -23.5505,
                origem_lng: -46.6333
            },
            {
                id: '2',
                origem: 'Paulista, São Paulo - SP',
                destino: 'Ibirapuera, São Paulo - SP',
                passageiro_nome: 'Lucia Fernandes',
                motorista_nome: 'Maria Santos',
                status: 'em_andamento',
                valor: 18.75,
                data_criacao: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
                origem_lat: -23.5505 + 0.01,
                origem_lng: -46.6333 + 0.01
            },
            {
                id: '3',
                origem: 'Liberdade, São Paulo - SP',
                destino: 'Morumbi, São Paulo - SP',
                passageiro_nome: 'Roberto Silva',
                motorista_nome: 'João Silva',
                status: 'aceita',
                valor: 32.00,
                data_criacao: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
                origem_lat: -23.5505 - 0.01,
                origem_lng: -46.6333 - 0.01
            }
        ],
        passageiros: [
            {
                id: '1',
                nome: 'Pedro Almeida',
                email: 'pedro.almeida@email.com',
                telefone: '(11) 55555-1111',
                total_corridas: 15,
                gasto_total: 380.50,
                data_cadastro: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString()
            },
            {
                id: '2',
                nome: 'Lucia Fernandes',
                email: 'lucia.fernandes@email.com',
                telefone: '(11) 44444-2222',
                total_corridas: 8,
                gasto_total: 195.25,
                data_cadastro: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
            },
            {
                id: '3',
                nome: 'Roberto Silva',
                email: 'roberto.silva@email.com',
                telefone: '(11) 33333-3333',
                total_corridas: 22,
                gasto_total: 567.80,
                data_cadastro: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString()
            }
        ]
    };
    
    console.log('Dados de exemplo carregados');
    updateAllInterfaces();
}

function updateAllInterfaces() {
    updateDashboard();
    updateMotoristas();
    updateCorridas();
    updatePassageiros();
    updateFinanceiro();
    updateMapMarkers();
    updateRealtimeMapData();
    hideLoading();
}

function showLoading() {
    document.querySelectorAll('.loading').forEach(el => {
        el.style.display = 'block';
    });
}

function hideLoading() {
    document.querySelectorAll('.loading').forEach(el => {
        el.style.display = 'none';
    });
}

// Dashboard
function updateDashboard() {
    // Atualizar contadores
    document.getElementById('totalMotoristas').textContent = allData.motoristas.length;
    document.getElementById('totalCorridas').textContent = allData.corridas.length;
    document.getElementById('totalPassageiros').textContent = allData.passageiros.length;
    
    // Calcular receita total
    const receitaTotal = allData.corridas
        .filter(c => c.status === 'concluida')
        .reduce((total, corrida) => total + (parseFloat(corrida.valor) || 0), 0);
    
    document.getElementById('receitaTotal').textContent = `R$ ${receitaTotal.toFixed(2)}`;
    
    // Atualizar atividade recente
    updateAtividadeRecente();
    
    // Atualizar motoristas online
    updateMotoristasOnline();
    
    // Atualizar gráficos
    updateCharts();
}

function updateAtividadeRecente() {
    const container = document.getElementById('atividadeRecente');
    const atividades = [
        { icon: 'fas fa-plus-circle', text: 'Novo motorista cadastrado', time: 'há 2 minutos' },
        { icon: 'fas fa-route', text: 'Corrida concluída', time: 'há 5 minutos' },
        { icon: 'fas fa-user-plus', text: 'Novo passageiro', time: 'há 10 minutos' }
    ];
    
    container.innerHTML = atividades.map(atividade => `
        <div class="activity-item">
            <i class="${atividade.icon}"></i>
            <span>${atividade.text}</span>
            <time>${atividade.time}</time>
        </div>
    `).join('');
}

function updateMotoristasOnline() {
    const container = document.getElementById('motoristasOnline');
    const motoristasOnline = allData.motoristas.filter(m => m.status === 'ativo');
    
    if (motoristasOnline.length === 0) {
        container.innerHTML = '<div class="online-item"><span>Nenhum motorista online</span></div>';
        return;
    }
    
    container.innerHTML = motoristasOnline.slice(0, 5).map(motorista => `
        <div class="online-item">
            <div class="online-status"></div>
            <span>${motorista.nome}</span>
        </div>
    `).join('');
}

// Gráficos
function initializeCharts() {
    // Gráfico de corridas por dia
    const corridasCtx = document.getElementById('corridasChart');
    if (corridasCtx) {
        charts.corridas = new Chart(corridasCtx, {
            type: 'line',
            data: {
                labels: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
                datasets: [{
                    label: 'Corridas',
                    data: [12, 19, 15, 25, 22, 30, 28],
                    borderColor: '#ff6b35',
                    backgroundColor: 'rgba(255, 107, 53, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
    
    // Gráfico de receita
    const receitaCtx = document.getElementById('receitaChart');
    if (receitaCtx) {
        charts.receita = new Chart(receitaCtx, {
            type: 'bar',
            data: {
                labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
                datasets: [{
                    label: 'Receita',
                    data: [1200, 1900, 1500, 2500, 2200, 3000],
                    backgroundColor: '#667eea'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
}

function updateCharts() {
    // Atualizar dados dos gráficos com dados reais
    if (charts.corridas) {
        // Lógica para atualizar gráfico de corridas
    }
    
    if (charts.receita) {
        // Lógica para atualizar gráfico de receita
    }
}

// Motoristas
function updateMotoristas() {
    const tbody = document.getElementById('motoristasTableBody');
    
    if (allData.motoristas.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Nenhum motorista encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = allData.motoristas.map(motorista => `
        <tr>
            <td>${motorista.nome || 'N/A'}</td>
            <td>${motorista.email || 'N/A'}</td>
            <td>${motorista.telefone || 'N/A'}</td>
            <td>${motorista.veiculo || 'N/A'}</td>
            <td><span class="badge badge-${motorista.status || 'pendente'}">${motorista.status || 'Pendente'}</span></td>
            <td>${motorista.avaliacao ? '⭐'.repeat(Math.floor(motorista.avaliacao)) + ` ${motorista.avaliacao}` : 'N/A'}</td>
            <td>
                ${(motorista.status === 'ativo' || motorista.status === 'online') ? 
                    `<button class="btn-sm" onclick="locateMotorista('${motorista.id}')" style="background: #007bff; color: white; margin-right: 5px;" title="Localizar no mapa">
                        <i class="fas fa-map-marker-alt"></i>
                    </button>` : ''
                }
                <button class="btn-sm btn-primary" onclick="editMotorista('${motorista.id}')">Editar</button>
                <button class="btn-sm btn-danger" onclick="deleteMotorista('${motorista.id}')">Excluir</button>
            </td>
        </tr>
    `).join('');
}

function filterMotoristas() {
    const search = document.getElementById('searchMotoristas').value.toLowerCase();
    const status = document.getElementById('statusFilter').value;
    
    let filtered = allData.motoristas;
    
    if (search) {
        filtered = filtered.filter(m => 
            (m.nome || '').toLowerCase().includes(search) ||
            (m.email || '').toLowerCase().includes(search)
        );
    }
    
    if (status) {
        filtered = filtered.filter(m => m.status === status);
    }
    
    // Atualizar tabela com dados filtrados
    const tbody = document.getElementById('motoristasTableBody');
    tbody.innerHTML = filtered.map(motorista => `
        <tr>
            <td>${motorista.nome || 'N/A'}</td>
            <td>${motorista.email || 'N/A'}</td>
            <td>${motorista.telefone || 'N/A'}</td>
            <td>${motorista.veiculo || 'N/A'}</td>
            <td><span class="badge badge-${motorista.status || 'pendente'}">${motorista.status || 'Pendente'}</span></td>
            <td>${motorista.avaliacao ? '⭐'.repeat(Math.floor(motorista.avaliacao)) + ` ${motorista.avaliacao}` : 'N/A'}</td>
            <td>
                ${(motorista.status === 'ativo' || motorista.status === 'online') ? 
                    `<button class="btn-sm" onclick="locateMotorista('${motorista.id}')" style="background: #007bff; color: white; margin-right: 5px;" title="Localizar no mapa">
                        <i class="fas fa-map-marker-alt"></i>
                    </button>` : ''
                }
                <button class="btn-sm btn-primary" onclick="editMotorista('${motorista.id}')">Editar</button>
                <button class="btn-sm btn-danger" onclick="deleteMotorista('${motorista.id}')">Excluir</button>
            </td>
        </tr>
    `).join('');
}

// Corridas
function updateCorridas() {
    const tbody = document.getElementById('corridasTableBody');
    
    if (allData.corridas.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="loading">Nenhuma corrida encontrada</td></tr>';
        return;
    }
    
    tbody.innerHTML = allData.corridas.map(corrida => `
        <tr>
            <td>#${corrida.id}</td>
            <td>${corrida.origem || 'N/A'}</td>
            <td>${corrida.destino || 'N/A'}</td>
            <td>${corrida.passageiro_nome || 'N/A'}</td>
            <td>${corrida.motorista_nome || 'N/A'}</td>
            <td><span class="badge badge-${corrida.status || 'pendente'}">${corrida.status || 'Pendente'}</span></td>
            <td>R$ ${corrida.valor || '0,00'}</td>
            <td>${formatDate(corrida.data_criacao)}</td>
            <td>
                <button class="btn-sm btn-primary" onclick="viewCorrida('${corrida.id}')">Ver</button>
            </td>
        </tr>
    `).join('');
}

function filterCorridas() {
    // Implementar filtro de corridas
}

// Passageiros
function updatePassageiros() {
    const tbody = document.getElementById('passageirosTableBody');
    
    if (allData.passageiros.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Nenhum passageiro encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = allData.passageiros.map(passageiro => `
        <tr>
            <td>${passageiro.nome || 'N/A'}</td>
            <td>${passageiro.email || 'N/A'}</td>
            <td>${passageiro.telefone || 'N/A'}</td>
            <td>${passageiro.total_corridas || 0}</td>
            <td>R$ ${passageiro.gasto_total || '0,00'}</td>
            <td>${formatDate(passageiro.data_cadastro)}</td>
            <td>
                <button class="btn-sm btn-primary" onclick="viewPassageiro('${passageiro.id}')">Ver</button>
            </td>
        </tr>
    `).join('');
}

function filterPassageiros() {
    // Implementar filtro de passageiros
}

// Financeiro
function updateFinanceiro() {
    const corridasConcluidas = allData.corridas.filter(c => c.status === 'concluida');
    const receitaTotal = corridasConcluidas.reduce((total, corrida) => total + (parseFloat(corrida.valor) || 0), 0);
    
    // Receita hoje (simulado)
    const receitaHoje = receitaTotal * 0.1;
    document.getElementById('receitaHoje').textContent = receitaHoje.toFixed(2);
    
    // Receita mês
    document.getElementById('receitaMes').textContent = receitaTotal.toFixed(2);
    
    // Comissão Vello (10%)
    const comissao = receitaTotal * 0.1;
    document.getElementById('comissaoVello').textContent = comissao.toFixed(2);
    
    // Pagamentos pendentes (simulado)
    document.getElementById('pagamentosPendentes').textContent = (receitaTotal * 0.05).toFixed(2);
}

// Relatórios
function gerarRelatorio(tipo) {
    alert(`Gerando relatório de ${tipo}...`);
    // Implementar geração de relatórios
}

function exportCorridas() {
    alert('Exportando corridas...');
    // Implementar exportação
}

function gerarRelatorioFinanceiro() {
    alert('Gerando relatório financeiro...');
    // Implementar relatório financeiro
}

// Modais e ações
function showModal(modalType) {
    alert(`Abrindo modal: ${modalType}`);
    // Implementar modais
}

function editMotorista(id) {
    alert(`Editando motorista: ${id}`);
    // Implementar edição
}

function deleteMotorista(id) {
    if (confirm('Tem certeza que deseja excluir este motorista?')) {
        alert(`Excluindo motorista: ${id}`);
        // Implementar exclusão
    }
}

function viewCorrida(id) {
    alert(`Visualizando corrida: ${id}`);
    // Implementar visualização
}

function viewPassageiro(id) {
    alert(`Visualizando passageiro: ${id}`);
    // Implementar visualização
}

// Tempo real
function setupRealTimeUpdates() {
    // Configurar listeners em tempo real
    try {
        onSnapshot(collection(db, 'motoristas'), (snapshot) => {
            allData.motoristas = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            updateDashboard();
            updateMotoristas();
            updateMapMarkers();
        });
        
        onSnapshot(collection(db, 'corridas'), (snapshot) => {
            allData.corridas = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            updateDashboard();
            updateCorridas();
            updateFinanceiro();
        });
        
        onSnapshot(collection(db, 'passageiros'), (snapshot) => {
            allData.passageiros = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            updateDashboard();
            updatePassageiros();
        });
    } catch (error) {
        console.error('Erro ao configurar atualizações em tempo real:', error);
    }
}

// Função para localizar motorista no mapa
function locateMotorista(motoristaId) {
    const motorista = allData.motoristas.find(m => m.id === motoristaId);
    if (motorista) {
        const lat = motorista.latitude || (-23.5505 + (Math.random() - 0.5) * 0.1);
        const lng = motorista.longitude || (-46.6333 + (Math.random() - 0.5) * 0.1);
        
        // Centralizar mapa na localização do motorista
        realtimeMap.setView([lat, lng], 16);
        
        // Encontrar e abrir popup do marcador
        realtimeMarkers.forEach(marker => {
            const pos = marker.getLatLng();
            if (Math.abs(pos.lat - lat) < 0.0001 && Math.abs(pos.lng - lng) < 0.0001) {
                marker.openPopup();
            }
        });
        
        console.log(`📍 Localizando motorista: ${motorista.nome || motoristaId}`);
    } else {
        alert('Motorista não encontrado');
    }
}

// Utilitários
function formatDate(dateString) {
    if (!dateString) return 'N/A';
    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('pt-BR') + ' ' + date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
    } catch {
        return 'N/A';
    }
}

// CSS adicional para badges
const style = document.createElement('style');
style.textContent = `
    .badge {
        padding: 0.25rem 0.5rem;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 500;
    }
    .badge-ativo { background: #d4edda; color: #155724; }
    .badge-inativo { background: #f8d7da; color: #721c24; }
    .badge-pendente { background: #fff3cd; color: #856404; }
    .badge-concluida { background: #d4edda; color: #155724; }
    .badge-cancelada { background: #f8d7da; color: #721c24; }
    .badge-em_andamento { background: #d1ecf1; color: #0c5460; }
    
    .btn-sm {
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
        border-radius: 4px;
        border: none;
        cursor: pointer;
        margin-right: 0.25rem;
    }
    .btn-sm.btn-primary { background: #007bff; color: white; }
    .btn-sm.btn-danger { background: #dc3545; color: white; }
    
    .custom-div-icon {
        background: none;
        border: none;
    }
`;
document.head.appendChild(style);

