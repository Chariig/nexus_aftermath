let inventoryData = [];
let itemDefs = {};
let currentTab = 'all';

window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.type) {
        case 'openInventory':
            openInventory(data);
            break;
        case 'closeInventory':
            closeAll();
            break;
        case 'updateInventory':
            inventoryData = data.inventory || [];
            renderInventory();
            break;
        case 'openCrafting':
            openCrafting(data);
            break;
        case 'openRadio':
            openRadio(data);
            break;
        case 'radioMessage':
            addRadioLogEntry(data.transmission);
            break;
        case 'closeRadio':
            document.getElementById('radio-container').classList.add('hidden');
            break;
    }
});

function openInventory(data) {
    inventoryData = data.inventory || [];
    itemDefs = data.items || {};
    document.getElementById('inventory-container').classList.remove('hidden');
    document.getElementById('crafting-container').classList.add('hidden');
    document.getElementById('radio-container').classList.add('hidden');
    currentTab = 'all';
    renderInventory();
    updateWeight();
}

function closeAll() {
    document.getElementById('inventory-container').classList.add('hidden');
    document.getElementById('crafting-container').classList.add('hidden');
    document.getElementById('radio-container').classList.add('hidden');
    fetch(`https://${(window.location.hostname || 'localhost')}/closeInventory`, {
        method: 'POST',
        body: JSON.stringify({}),
        headers: { 'Content-Type': 'application/json' }
    });
}

function renderInventory() {
    const grid = document.getElementById('inventory-grid');
    grid.innerHTML = '';

    const filtered = currentTab === 'all'
        ? inventoryData
        : inventoryData.filter(item => {
            const def = itemDefs[item.name];
            return def && def.category === currentTab;
        });

    for (let i = 0; i < 50; i++) {
        const slot = document.createElement('div');
        slot.className = 'inv-slot';
        slot.dataset.slot = i;

        const item = inventoryData[i];
        if (item) {
            const def = itemDefs[item.name];
            slot.classList.add('has-item');

            const icon = document.createElement('div');
            icon.className = 'item-icon';
            icon.textContent = getItemIcon(item.name, def);
            slot.appendChild(icon);

            const name = document.createElement('div');
            name.className = 'item-name';
            name.textContent = def ? def.label : item.name;
            slot.appendChild(name);

            if (item.count > 1) {
                const count = document.createElement('div');
                count.className = 'item-count';
                count.textContent = 'x' + item.count;
                slot.appendChild(count);
            }

            slot.addEventListener('click', (e) => {
                e.stopPropagation();
                if (def && (def.type === 'consumable' || def.type === 'weapon')) {
                    fetch(`https://${(window.location.hostname || 'localhost')}/useItem`, {
                        method: 'POST',
                        body: JSON.stringify({ itemName: item.name, slot: i }),
                        headers: { 'Content-Type': 'application/json' }
                    });
                }
            });

            slot.addEventListener('contextmenu', (e) => {
                e.preventDefault();
                fetch(`https://${(window.location.hostname || 'localhost')}/dropItem`, {
                    method: 'POST',
                    body: JSON.stringify({ slot: i, count: 1 }),
                    headers: { 'Content-Type': 'application/json' }
                });
            });

            slot.addEventListener('mouseenter', (e) => {
                showTooltip(e, item, def);
            });
            slot.addEventListener('mouseleave', hideTooltip);
        }

        grid.appendChild(slot);
    }

    updateWeight();
}

function getItemIcon(name, def) {
    const icons = {
        'weapons': '\u{1F52B}',
        'medical': '\u{2695}\uFE0F',
        'food': '\u{1F372}',
        'materials': '\u{2692}\uFE0F',
        'tools': '\u{1F527}',
        'electronics': '\u{1F4F1}',
        'chemicals': '\u{2697}\uFE0F',
        'rare': '\u{2B50}',
        'infection': '\u{2620}\uFE0F',
        'lore': '\u{1F4DC}',
    };
    if (def && def.category) {
        return icons[def.category] || '\u{1F4E6}';
    }
    return '\u{1F4E6}';
}

function showTooltip(event, item, def) {
    const tooltip = document.getElementById('item-tooltip');
    document.getElementById('tooltip-name').textContent = def ? def.label : item.name;
    document.getElementById('tooltip-desc').textContent = def ? def.description : '';
    const stats = [];
    if (def) {
        if (def.healAmount) stats.push('Heals: ' + def.healAmount);
        if (def.hunger) stats.push('Hunger: +' + def.hunger);
        if (def.thirst) stats.push('Thirst: +' + def.thirst);
        if (def.damage) stats.push('Damage: ' + def.damage);
        if (def.durability) stats.push('Durability: ' + (item.metadata && item.metadata.durability || def.durability) + '/' + def.durability);
        if (def.decay && def.decay > 0) stats.push('Decays in: ' + formatDecay(def.decay));
        if (def.weight) stats.push('Weight: ' + def.weight + 'kg');
    }
    document.getElementById('tooltip-stats').textContent = stats.join(' | ');

    tooltip.style.left = (event.clientX + 15) + 'px';
    tooltip.style.top = (event.clientY + 15) + 'px';
    tooltip.classList.remove('hidden');
}

function hideTooltip() {
    document.getElementById('item-tooltip').classList.add('hidden');
}

function updateWeight() {
    let total = 0;
    inventoryData.forEach(item => {
        const def = itemDefs[item.name];
        total += (def ? def.weight || 0.1 : 0.1) * item.count;
    });
    document.getElementById('weight-display').textContent = total.toFixed(1) + ' / 100 kg';
}

function formatDecay(seconds) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    if (h > 0) return h + 'h ' + m + 'm';
    return m + 'm';
}

document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        currentTab = tab.dataset.tab;
        renderInventory();
    });
});

document.getElementById('close-btn').addEventListener('click', closeAll);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeAll();
});

function openCrafting(data) {
    document.getElementById('crafting-container').classList.remove('hidden');
    document.getElementById('inventory-container').classList.add('hidden');
    document.getElementById('radio-container').classList.add('hidden');

    const grid = document.getElementById('crafting-grid');
    grid.innerHTML = '';

    const recipes = data.recipes || {};
    const skills = data.skills || {};

    Object.entries(recipes).forEach(([name, recipe]) => {
        const el = document.createElement('div');
        el.className = 'craft-recipe';

        const skillLevel = skills[recipe.skill] || 0;
        const locked = skillLevel < recipe.skillReq;
        if (locked) el.classList.add('locked');

        const nameEl = document.createElement('div');
        nameEl.className = 'recipe-name';
        nameEl.textContent = recipe.label;
        el.appendChild(nameEl);

        const ingredients = document.createElement('div');
        ingredients.className = 'recipe-ingredients';
        const ingList = Object.entries(recipe.ingredients)
            .map(([ing, count]) => (itemDefs[ing] ? itemDefs[ing].label : ing) + ' x' + count)
            .join(', ');
        ingredients.textContent = 'Needs: ' + ingList;
        el.appendChild(ingredients);

        const result = document.createElement('div');
        result.className = 'recipe-ingredients';
        const resDef = itemDefs[recipe.result.name];
        result.textContent = '-> ' + (resDef ? resDef.label : recipe.result.name) + ' x' + recipe.result.count;
        el.appendChild(result);

        const skillEl = document.createElement('div');
        skillEl.className = 'recipe-skill';
        skillEl.textContent = recipe.skill + ': ' + skillLevel + '/' + recipe.skillReq + (locked ? ' (LOCKED)' : '');
        el.appendChild(skillEl);

        if (!locked) {
            el.addEventListener('click', () => {
                fetch(`https://${(window.location.hostname || 'localhost')}/craftItem`, {
                    method: 'POST',
                    body: JSON.stringify({ recipeName: name }),
                    headers: { 'Content-Type': 'application/json' }
                });
            });
        }

        grid.appendChild(el);
    });
}

document.getElementById('crafting-close-btn').addEventListener('click', closeAll);

function openRadio(data) {
    document.getElementById('radio-container').classList.remove('hidden');
    document.getElementById('inventory-container').classList.add('hidden');
    document.getElementById('crafting-container').classList.add('hidden');

    const freq = data.frequency || 420;
    document.getElementById('radio-freq-slider').value = freq;
    document.getElementById('radio-freq-display').textContent = freq.toFixed(1) + ' MHz';
    document.getElementById('radio-log').innerHTML = '';
}

document.getElementById('radio-close-btn').addEventListener('click', closeAll);

document.getElementById('radio-freq-slider').addEventListener('input', (e) => {
    const freq = parseFloat(e.target.value);
    document.getElementById('radio-freq-display').textContent = freq.toFixed(1) + ' MHz';
});

document.getElementById('radio-set-btn').addEventListener('click', () => {
    const freq = parseFloat(document.getElementById('radio-freq-slider').value);
    fetch(`https://${(window.location.hostname || 'localhost')}/setRadioFreq`, {
        method: 'POST',
        body: JSON.stringify({ frequency: freq }),
        headers: { 'Content-Type': 'application/json' }
    });
});

document.getElementById('radio-send-btn').addEventListener('click', () => {
    const message = document.getElementById('radio-message').value.trim();
    if (!message) return;
    const encrypted = document.getElementById('radio-encrypt').checked;
    fetch(`https://${(window.location.hostname || 'localhost')}/radioTransmit`, {
        method: 'POST',
        body: JSON.stringify({ message, encrypted }),
        headers: { 'Content-Type': 'application/json' }
    });
    document.getElementById('radio-message').value = '';
});

document.getElementById('radio-message').addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        document.getElementById('radio-send-btn').click();
    }
});

function addRadioLogEntry(transmission) {
    const log = document.getElementById('radio-log');
    const entry = document.createElement('div');
    entry.className = 'radio-log-entry';
    const timestamp = new Date().toLocaleTimeString();
    entry.innerHTML = `<span class="freq">[${Math.floor(transmission.frequency)} MHz]</span> <span class="sender">${transmission.playerName}</span>: <span class="msg">${transmission.message}</span>`;
    log.appendChild(entry);
    log.scrollTop = log.scrollHeight;
}
