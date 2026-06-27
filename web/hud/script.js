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
        case 'showSelector':
            showSelector(data.characters);
            break;
        case 'showCreator':
            showCreator();
            break;
        case 'closeSelector':
            closeSelector();
            break;
        case 'closeCreator':
            closeCreator();
            break;
    }
});

function nuiFetch(name, data) {
    const url = 'https://' + document.domain + '/' + name;
    console.log('nuiFetch:', url, JSON.stringify(data));
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).then(r => {
        if (!r.ok) console.error('nuiFetch ' + name + ' status:', r.status);
        return r;
    }).catch(err => {
        console.error('nuiFetch ' + name + ' error:', err);
    });
}

function showSelector(chars) {
    var hud = document.getElementById('hud');
    var screen = document.getElementById('selector-screen');
    if (!hud || !screen) return;
    hud.classList.add('hidden');
    screen.classList.remove('hidden');

    var list = document.getElementById('char-list');
    if (!list) return;
    list.innerHTML = '';

    if (chars && chars.length > 0) {
        chars.forEach(function(c) {
            var card = document.createElement('div');
            card.className = 'char-card';
            card.innerHTML = '<div class="char-name">' + escapeHtml(c.firstname || '') + ' ' + escapeHtml(c.lastname || '') + '</div><div class="char-info">' + escapeHtml(c.gender || '?') + ' &middot; ' + escapeHtml(c.dateofbirth || '??') + '</div>';
            card.addEventListener('click', function() {
                nuiFetch('selectCharacter', { citizenId: c.citizenId });
            });
            list.appendChild(card);
        });
    } else {
        list.innerHTML = '<div class="no-chars">No survivors found. Create one.</div>';
    }

    var btn = document.getElementById('new-char-btn');
    if (btn) btn.onclick = function() { nuiFetch('newCharacter', {}); };
}

function closeSelector() {
    var el = document.getElementById('selector-screen');
    var hud = document.getElementById('hud');
    if (el) el.classList.add('hidden');
    if (hud) hud.classList.remove('hidden');
}

function showCreator() {
    var sel = document.getElementById('selector-screen');
    var cr = document.getElementById('creator-screen');
    if (sel) sel.classList.add('hidden');
    if (cr) cr.classList.remove('hidden');
}

function closeCreator() {
    var cr = document.getElementById('creator-screen');
    var sel = document.getElementById('selector-screen');
    if (cr) cr.classList.add('hidden');
    if (sel) sel.classList.remove('hidden');
}

function getAppearanceData() {
    var data = { features: {} };
    document.querySelectorAll('#panel-face input[data-feature]').forEach(function(el) {
        data.features[el.dataset.feature] = parseFloat(el.value);
    });
    data.hair = {
        style: parseInt(document.getElementById('hair-style').value),
        color: parseInt(document.getElementById('hair-color').value),
        highlight: parseInt(document.getElementById('hair-highlight').value)
    };
    data.eyebrows = {
        style: parseInt(document.getElementById('eyebrow-style').value),
        color: parseInt(document.getElementById('eyebrow-color').value),
        opacity: parseFloat(document.getElementById('eyebrow-opacity').value)
    };
    data.beard = {
        style: parseInt(document.getElementById('beard-style').value),
        color: parseInt(document.getElementById('beard-color').value)
    };
    data.blemishes = parseInt(document.getElementById('blemish-style').value);
    data.ageing = parseInt(document.getElementById('ageing-style').value);
    data.complexion = parseInt(document.getElementById('complexion-style').value);
    data.freckles = parseInt(document.getElementById('freckle-style').value);
    data.eyeColor = parseInt(document.getElementById('eye-color').value);
    data.makeup = parseInt(document.getElementById('makeup-style').value);
    data.blush = parseInt(document.getElementById('blush-style').value);
    data.lipstick = parseInt(document.getElementById('lipstick-style').value);
    data.chest = parseInt(document.getElementById('chest-style').value);
    data.bodyBlemishes = parseInt(document.getElementById('bodyblemish-style').value);
    return data;
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded - setting up UI');

    var ev = document.getElementById('event-notification');
    var iw = document.getElementById('infection-warning');
    var ti = document.getElementById('tether-indicator');
    var vh = document.getElementById('vehicle-hud');
    if (ev) ev.classList.add('hidden');
    if (iw) iw.classList.add('hidden');
    if (ti) ti.classList.add('hidden');
    if (vh) vh.classList.add('hidden');

    document.querySelectorAll('.tab-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
            btn.classList.add('active');
            document.querySelectorAll('.panel').forEach(function(p) { p.classList.add('hidden'); });
            var panel = document.getElementById('panel-' + btn.dataset.tab);
            if (panel) panel.classList.remove('hidden');
        });
    });

    var cancelBtn = document.getElementById('cancel-char-btn');
    if (cancelBtn) cancelBtn.addEventListener('click', function() {
        nuiFetch('cancelCharacter', {});
    });

    var saveBtn = document.getElementById('save-char-btn');
    if (saveBtn) saveBtn.addEventListener('click', function() {
        console.log('Save & Play clicked');
        var firstname = document.getElementById('c-firstname');
        var lastname = document.getElementById('c-lastname');
        if (!firstname || !lastname) { console.error('Name inputs not found'); return; }
        var fn = firstname.value.trim();
        var ln = lastname.value.trim();
        if (!fn || !ln) {
            alert('First and last name required.');
            return;
        }
        var data = {
            firstname: fn,
            lastname: ln,
            gender: document.getElementById('c-gender').value,
            dateofbirth: document.getElementById('c-dob').value || 'Unknown',
            appearance: getAppearanceData()
        };
        nuiFetch('saveCharacter', data);
    });

    document.querySelectorAll('#creator-panels input[type="range"]').forEach(function(el) {
        el.addEventListener('input', function() {
            nuiFetch('updateAppearance', getAppearanceData());
        });
    });

    console.log('UI setup complete');
});

window.onerror = function(msg, url, line, col, error) {
    console.error('JS Error:', msg, 'at', url, line + ':' + col);
    return false;
};

function escapeHtml(str) {
    var d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
}

function updateHUD(d) {
    var healthFill = document.getElementById('health-fill');
    var healthText = document.getElementById('health-text');
    if (healthFill) healthFill.style.width = Math.max(0, (d.health / 200) * 100) + '%';
    if (healthText) healthText.textContent = Math.floor(d.health);

    var armorFill = document.getElementById('armor-fill');
    var armorText = document.getElementById('armor-text');
    if (armorFill) armorFill.style.width = Math.min(100, d.armor) + '%';
    if (armorText) armorText.textContent = Math.floor(d.armor);

    var hungerFill = document.getElementById('hunger-fill');
    if (hungerFill) hungerFill.style.width = d.hunger + '%';
    var thirstFill = document.getElementById('thirst-fill');
    if (thirstFill) thirstFill.style.width = d.thirst + '%';

    var infWarn = document.getElementById('infection-warning');
    if (d.infection && d.infection.strain) {
        if (infWarn) {
            infWarn.classList.remove('hidden');
            var infFill = document.getElementById('infection-fill');
            if (infFill) infFill.style.width = (d.infection.level || 0) + '%';
            var infLabel = document.getElementById('infection-label');
            if (infLabel) {
                var stage = d.infection.level >= 80 ? 'FINAL' : d.infection.level >= 60 ? 'CRITICAL' : d.infection.level >= 40 ? 'ADVANCED' : d.infection.level >= 20 ? 'EARLY' : 'EXPOSED';
                infLabel.textContent = stage + ' - ' + d.infection.strain;
            }
        }
    } else {
        if (infWarn) infWarn.classList.add('hidden');
    }

    var loc = document.getElementById('location');
    if (loc) loc.textContent = d.location || 'Unknown';
    var zone = document.getElementById('zone');
    if (zone) zone.textContent = d.area || 'San Andreas';

    var tier = document.getElementById('world-tier');
    if (tier) {
        tier.textContent = d.tier ? d.tier.toUpperCase() : 'SAFE';
        tier.style.color = HUD.tierColors[d.tier] || '#4caf50';
    }

    var pc = document.getElementById('player-count');
    if (pc) pc.textContent = (d.playerCount || 0) + ' survivors';

    var radioEl = document.getElementById('radio-display');
    if (radioEl) {
        if (d.radioFreq && d.radioFreq > 0) {
            radioEl.textContent = Math.floor(d.radioFreq) + ' MHz';
            radioEl.style.display = 'block';
        } else {
            radioEl.textContent = '--- MHz';
        }
    }

    var tetherInd = document.getElementById('tether-indicator');
    if (tetherInd) {
        if (d.tethered && d.tethered.length > 0) {
            tetherInd.classList.remove('hidden');
            tetherInd.textContent = '\u{1F517} Tethered (' + d.tethered.length + ')';
        } else {
            tetherInd.classList.add('hidden');
        }
    }

    var vehicleHUD = document.getElementById('vehicle-hud');
    if (vehicleHUD) {
        if (d.inVehicle) {
            vehicleHUD.classList.remove('hidden');
            var sd = document.getElementById('speed-display');
            if (sd) sd.textContent = d.speed || 0;
            var ff = document.getElementById('fuel-fill');
            if (ff) ff.style.width = (d.fuel || 0) + '%';
            var gd = document.getElementById('gear-display');
            if (gd) gd.textContent = d.gear ? 'D' + Math.floor(d.gear) : 'N';
            var rf = document.getElementById('rpm-fill');
            if (rf) rf.style.width = ((d.rpm || 0) * 100) + '%';
        } else {
            vehicleHUD.classList.add('hidden');
        }
    }

    if (d.skills) {
        document.querySelectorAll('.skill').forEach(function(el) {
            var skillName = el.dataset.skill;
            var level = d.skills[skillName] || 0;
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
    var el = document.getElementById('event-notification');
    if (!el) return;
    el.classList.remove('hidden');
    var title = document.getElementById('event-title');
    var desc = document.getElementById('event-desc');
    if (title) title.textContent = eventData.label;
    if (desc) desc.textContent = eventData.description;
    var tier = document.getElementById('world-tier');
    if (tier) el.style.borderColor = tier.style.color || '#fff';
    setTimeout(function() {
        el.classList.add('hidden');
    }, 8000);
}

function hideWorldEvent() {
    var el = document.getElementById('event-notification');
    if (el) el.classList.add('hidden');
}
