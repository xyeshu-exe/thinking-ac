// =============================================
//      DASHBOARD MAIN APP (web/js/app.js)
// =============================================

document.addEventListener('DOMContentLoaded', () => {
    // ─── STATE ────────────────────────────────────────────────
    let currentTab = 'overview';
    let players = [];
    let bans = [];

    // ─── ELEMENTS ─────────────────────────────────────────────
    const tabBtns      = document.querySelectorAll('.nav-btn');
    const tabPanes     = document.querySelectorAll('.tab-pane');
    const tabTitle     = document.getElementById('tab-title');
    const refreshBtn   = document.getElementById('refresh-btn');
    const playerSearch = document.getElementById('player-search');
    const modal        = document.getElementById('modal-backdrop');

    // ─── TAB SWITCHING ────────────────────────────────────────
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.getAttribute('data-tab');
            switchTab(tabId);
        });
    });

    function switchTab(tabId) {
        currentTab = tabId;
        tabBtns.forEach(b => b.classList.toggle('active', b.getAttribute('data-tab') === tabId));
        tabPanes.forEach(p => p.classList.toggle('active', p.id === tabId));
        tabTitle.textContent = tabId.charAt(0).toUpperCase() + tabId.slice(1);
        loadTabData();
    }

    // ─── DATA LOADING ─────────────────────────────────────────
    async function loadTabData() {
        try {
            if (currentTab === 'overview') {
                const stats = await API.getStats();
                const alerts = await API.getAlerts();
                renderOverview(stats, alerts);
            } else if (currentTab === 'players') {
                players = await API.getPlayers();
                renderPlayers(players);
            } else if (currentTab === 'bans') {
                bans = await API.getBans();
                renderBans(bans);
            } else if (currentTab === 'config') {
                const config = await API.getConfig();
                renderConfig(config);
            }
        } catch (e) {
            showToast(e.message, 'danger');
        }
    }

    // ─── RENDERING ────────────────────────────────────────────
    function renderOverview(stats, alerts) {
        document.getElementById('stat-alerts').textContent = stats.alertCount;
        document.getElementById('stat-players').textContent = stats.playerCount;
        document.getElementById('stat-bans').textContent = stats.banCount;

        const tbody = document.querySelector('#alerts-table tbody');
        tbody.innerHTML = alerts.map(a => `
            <tr>
                <td><span class="dim">${a.time || 'N/A'}</span></td>
                <td><strong>${a.player}</strong></td>
                <td><span class="badge ${a.type}">${a.type.toUpperCase()}</span></td>
                <td>${a.reason}</td>
            </tr>
        `).join('') || '<tr><td colspan="4" class="center dim">No active alerts recorded.</td></tr>';
    }

    function renderPlayers(list) {
        const tbody = document.querySelector('#players-table tbody');
        const filter = playerSearch.value.toLowerCase();
        const filtered = list.filter(p => p.name.toLowerCase().includes(filter) || p.id.toString().includes(filter));

        tbody.innerHTML = filtered.map(p => `
            <tr>
                <td>${p.id}</td>
                <td><strong>${p.name}</strong></td>
                <td class="${p.ping > 100 ? 'warning' : 'success'}">${p.ping}ms</td>
                <td class="dim small">${p.license}</td>
                <td>
                    <div class="action-btns">
                        <button class="btn-small btn-kick" onclick="confirmAction('kick', ${p.id}, '${p.name}')">Kick</button>
                        <button class="btn-small btn-ban" onclick="confirmAction('ban', ${p.id}, '${p.name}')">Ban</button>
                    </div>
                </td>
            </tr>
        `).join('') || '<tr><td colspan="5" class="center dim">No players online matching search.</td></tr>';
    }

    function renderBans(list) {
        const tbody = document.querySelector('#bans-table tbody');
        tbody.innerHTML = list.map(b => `
            <tr>
                <td><span class="dim">${b.date}</span></td>
                <td><strong>${b.name || 'Unknown'}</strong></td>
                <td class="dim small">${b.id}</td>
                <td>${b.reason}</td>
                <td>
                    <button class="btn-small btn-unban" onclick="confirmAction('unban', '${b.id}', '${b.name}')">Unban</button>
                </td>
            </tr>
        `).join('') || '<tr><td colspan="5" class="center dim">No players banned.</td></tr>';
    }

    function renderConfig(cfg) {
        const container = document.getElementById('config-fields');
        let html = '';

        // Dynamically build form for nested config
        for (const [key, value] of Object.entries(cfg)) {
            if (typeof value === 'object' && !Array.isArray(value)) {
                html += `<div class="config-group"><h3>${key.toUpperCase()}</h3>`;
                for (const [subKey, subVal] of Object.entries(value)) {
                    if (typeof subVal !== 'object') {
                        const id = `${key}_${subKey}`;
                        html += `
                            <div class="config-item">
                                <label>${subKey}</label>
                                ${typeof subVal === 'boolean' 
                                    ? `<select data-group="${key}" data-key="${subKey}">
                                        <option value="true" ${subVal ? 'selected' : ''}>Enabled</option>
                                        <option value="false" ${!subVal ? 'selected' : ''}>Disabled</option>
                                      </select>`
                                    : `<input type="${typeof subVal === 'number' ? 'number' : 'text'}" 
                                              data-group="${key}" data-key="${subKey}" value="${subVal}">`
                                }
                            </div>
                        `;
                    }
                }
                html += `</div>`;
            }
        }
        container.innerHTML = html;
    }

    // ─── ACTIONS ──────────────────────────────────────────────
    window.confirmAction = (type, id, name) => {
        const title = document.getElementById('modal-title');
        const body = document.getElementById('modal-body');
        const confirmBtn = document.getElementById('modal-confirm');

        title.textContent = `${type.toUpperCase()} Player`;
        body.innerHTML = `Are you sure you want to <strong>${type}</strong> <strong>${name}</strong>?`;
        
        modal.classList.remove('hidden');

        confirmBtn.onclick = async () => {
            try {
                if (type === 'kick') await API.kickPlayer(id, 'Admin Action');
                if (type === 'ban') await API.banPlayer(id, 'Admin Action');
                if (type === 'unban') await API.unbanPlayer(id);
                
                showToast(`Success: ${type}d ${name}`, 'success');
                modal.classList.add('hidden');
                loadTabData();
            } catch (e) {
                showToast(e.message, 'danger');
            }
        };
    };

    document.getElementById('modal-cancel').onclick = () => modal.classList.add('hidden');
    
    document.getElementById('config-form').onsubmit = async (e) => {
        e.preventDefault();
        const inputs = e.target.querySelectorAll('input, select');
        const update = {};
        inputs.forEach(el => {
            const group = el.getAttribute('data-group');
            const key = el.getAttribute('data-key');
            let val = el.value;
            if (val === 'true') val = true;
            if (val === 'false') val = false;
            if (el.type === 'number') val = parseFloat(val);

            if (!update[group]) update[group] = {};
            update[group][key] = val;
        });

        try {
            await API.updateConfig(update);
            showToast("Runtime configuration updated!", 'success');
        } catch (e) {
            showToast(e.message, 'danger');
        }
    };

    // ─── UTILS ────────────────────────────────────────────────
    function showToast(msg, type) {
        // Simple console log for now, can add a proper toast UI later
        alert(msg);
    }

    refreshBtn.onclick = loadTabData;
    playerSearch.oninput = () => renderPlayers(players);

    // Initial load
    loadTabData();
    // Auto refresh every 10 seconds
    setInterval(loadTabData, 10000);
});
