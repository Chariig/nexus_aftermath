const HUD = {
    tierColors: {
        safe: '#4caf50',
        unstable: '#ff9800',
        critical: '#f44336',
        collapse: '#9c27b0'
    }
};

window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.type) {
        case 'updateHUD':
            updateHUD(data.data);
            break;
        case 'worldEvent':
            showWorldEvent(data.event);
            break;
        case 'worldEventEnded':
            hideWorldEvent();
            break;
    }
});

function updateHUD(d) {
    const health = document.getElementById('health-fill');
    const healthText = document.getElementById('health-text');
    health.style.width = Math.max(0, (d.health / 200) * 100) + '%';
    healthText.textContent = Math.floor(d.health);

    const armor = document.getElementById('armor-fill');
    const armorText = document.getElementById('armor-text');
    armor.style.width = Math.min(100, d.armor) + '%';
    armorText.textContent = Math.floor(d.armor);

    document.getElementById('hunger-fill').style.width = d.hunger + '%';
    document.getElementById('thirst-fill').style.width = d.thirst + '%';

    const infWarn = document.getElementById('infection-warning');
    if (d.infection && d.infection.strain) {
        infWarn.classList.remove('hidden');
        const infFill = document.getElementById('infection-fill');
        infFill.style.width = (d.infection.level || 0) + '%';
        const stage = d.infection.level >= 80 ? 'FINAL' : d.infection.level >= 60 ? 'CRITICAL' : d.infection.level >= 40 ? 'ADVANCED' : d.infection.level >= 20 ? 'EARLY' : 'EXPOSED';
        document.getElementById('infection-label').textContent = stage + ' - ' + d.infection.strain;
    } else {
        infWarn.classList.add('hidden');
    }

    document.getElementById('location').textContent = d.location || 'Unknown';
    document.getElementById('zone').textContent = d.area || 'San Andreas';

    const tier = document.getElementById('world-tier');
    tier.textContent = d.tier ? d.tier.toUpperCase() : 'SAFE';
    tier.style.color = HUD.tierColors[d.tier] || '#4caf50';

    document.getElementById('player-count').textContent = (d.playerCount || 0) + ' survivors';

    const radioEl = document.getElementById('radio-display');
    if (d.radioFreq && d.radioFreq > 0) {
        radioEl.textContent = Math.floor(d.radioFreq) + ' MHz';
        radioEl.style.display = 'block';
    } else {
        radioEl.textContent = '--- MHz';
    }

    const tetherInd = document.getElementById('tether-indicator');
    if (d.tethered && d.tethered.length > 0) {
        tetherInd.classList.remove('hidden');
        tetherInd.textContent = '\u{1F517} Tethered (' + d.tethered.length + ')';
    } else {
        tetherInd.classList.add('hidden');
    }

    const vehicleHUD = document.getElementById('vehicle-hud');
    if (d.inVehicle) {
        vehicleHUD.classList.remove('hidden');
        document.getElementById('speed-display').textContent = d.speed || 0;
        document.getElementById('fuel-fill').style.width = (d.fuel || 0) + '%';
        document.getElementById('gear-display').textContent = d.gear ? 'D' + Math.floor(d.gear) : 'N';
        const rpmPct = (d.rpm || 0) * 100;
        document.getElementById('rpm-fill').style.width = rpmPct + '%';
    } else {
        vehicleHUD.classList.add('hidden');
    }

    if (d.skills) {
        document.querySelectorAll('.skill').forEach(el => {
            const skillName = el.dataset.skill;
            const level = d.skills[skillName] || 0;
            if (level > 0) {
                el.classList.add('active');
                el.title = skillName + ': ' + level;
            } else {
                el.classList.remove('active');
            }
        });
    }
}

function showWorldEvent(eventData) {
    const el = document.getElementById('event-notification');
    el.classList.remove('hidden');
    document.getElementById('event-title').textContent = eventData.label;
    document.getElementById('event-desc').textContent = eventData.description;
    const tier = document.getElementById('world-tier');
    el.style.borderColor = tier.style.color || '#fff';

    setTimeout(() => {
        el.classList.add('hidden');
    }, 8000);
}

function hideWorldEvent() {
    document.getElementById('event-notification').classList.add('hidden');
}

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('event-notification').classList.add('hidden');
    document.getElementById('infection-warning').classList.add('hidden');
    document.getElementById('tether-indicator').classList.add('hidden');
    document.getElementById('vehicle-hud').classList.add('hidden');
});
