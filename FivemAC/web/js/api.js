// =============================================
//      DASHBOARD API HELPER (web/js/api.js)
// =============================================

const API = {
    // Port and Token will be used if the panel is hosted elsewhere, 
    // but usually it's same origin for FiveM.
    token: new URLSearchParams(window.location.search).get('token') || "CHANGE_ME_NOW_123",

    async request(path, method = 'GET', body = null) {
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                'X-AC-Token': this.token
            }
        };
        if (body) options.body = JSON.stringify(body);

        try {
            const resp = await fetch(path, options);
            if (!resp.ok) {
                const err = await resp.json();
                throw new Error(err.error || `HTTP ${resp.status}`);
            }
            return await resp.json();
        } catch (e) {
            console.error(`API Error (${path}):`, e);
            throw e;
        }
    },

    getPlayers()  { return this.request('/api/players'); },
    getAlerts()   { return this.request('/api/alerts'); },
    getBans()     { return this.request('/api/bans'); },
    getStats()    { return this.request('/api/stats'); },
    getConfig()   { return this.request('/api/config'); },
    
    kickPlayer(id, reason)    { return this.request('/api/kick', 'POST', { id, reason }); },
    banPlayer(id, reason)     { return this.request('/api/ban', 'POST', { id, reason }); },
    unbanPlayer(license)      { return this.request('/api/unban', 'POST', { license }); },
    updateConfig(config)      { return this.request('/api/config', 'POST', config); },
    announce(message)         { return this.request('/api/announce', 'POST', { message }); }
};
