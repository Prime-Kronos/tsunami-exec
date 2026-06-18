import { world, system } from '@minecraft/server';

const TITAN_RING_ID = 'aot:titan_transformation_ring';
const TITAN_ENTITY = 'aot:colossal_titan';
const TRANSFORMATION_DURATION = 50; // ticks
const TITAN_FORM_DURATION = 400; // ticks ≈ 20 seconds

let playerTitanState = new Map();

// Main item use event
world.afterEvents.itemUse.subscribe((event) => {
  const player = event.source;
  const item = event.itemStack;
  
  if (item.typeId === TITAN_RING_ID) {
    if (!playerTitanState.has(player.id)) {
      startTitanTransformation(player);
    } else {
      player.sendMessage('\u00a7cYou are already transforming or in titan form!');
    }
  }
});

function startTitanTransformation(player) {
  const playerId = player.id;
  
  try {
    player.addTag('titan_transforming');
    playerTitanState.set(playerId, {
      isTransforming: true,
      startTime: system.currentTick,
      playerName: player.name
    });
    
    player.sendMessage('\u00a7c\u00a7lTITAN TRANSFORMATION INITIATED!');
    
    // Play sounds and particles
    player.dimension.runCommandAsync(`playsound mob.wither.spawn @a ~~~ 2 0.5`);
    player.dimension.runCommandAsync(`particle minecraft:large_explosion ~~~`);
    player.dimension.runCommandAsync(`particle minecraft:wither_boss_invulnerable ~~~`);
    
    // Schedule transformation completion
    system.runTimeout(() => {
      completeTitanTransformation(player);
    }, TRANSFORMATION_DURATION);
    
  } catch (error) {
    console.warn(`Transformation error: ${error}`);
    player.sendMessage('\u00a7cTransformation failed!');
    playerTitanState.delete(playerId);
  }
}

function completeTitanTransformation(player) {
  const playerId = player.id;
  
  try {
    const pos = player.location;
    
    // Spawn titan entity
    const titan = player.dimension.spawnEntity(TITAN_ENTITY, {
      x: pos.x,
      y: pos.y,
      z: pos.z
    });
    
    if (!titan) {
      throw new Error('Failed to spawn titan entity');
    }
    
    // Link titan to player
    titan.addTag(`titan_owner_${playerId}`);
    titan.nameTag = `${player.name}'s Titan`;
    
    player.removeTag('titan_transforming');
    player.addTag('is_titan');
    
    // Apply effects
    player.dimension.runCommandAsync(`effect @s strength 20 3 true`);
    player.dimension.runCommandAsync(`effect @s speed 20 2 true`);
    player.dimension.runCommandAsync(`effect @s resistance 20 1 true`);
    
    player.sendMessage('\u00a74\u00a7l=== TITAN FORM ACTIVATED ===');
    player.sendMessage('\u00a76Power Duration: 20 seconds');
    player.sendMessage('\u00a76Health: 600 | Damage: 30');
    
    // Create explosion effect
    player.dimension.runCommandAsync(`particle minecraft:explosion_particle ~~~`);
    player.dimension.runCommandAsync(`playsound mob.wither.death @a ~~~ 1.5 0.7`);
    
    // Store titan reference
    playerTitanState.set(playerId, {
      isTransforming: false,
      isTitan: true,
      startTime: system.currentTick,
      titanEntity: titan,
      playerName: player.name
    });
    
    // Remove titan form after duration
    system.runTimeout(() => {
      endTitanForm(player, titan);
    }, TITAN_FORM_DURATION);
    
  } catch (error) {
    console.warn(`Completion error: ${error}`);
    player.sendMessage('\u00a7cFailed to complete transformation!');
    playerTitanState.delete(playerId);
  }
}

function endTitanForm(player, titan) {
  const playerId = player.id;
  
  try {
    player.removeTag('is_titan');
    player.removeTag('titan_transforming');
    
    // Clear effects
    player.dimension.runCommandAsync(`effect @s clear`);
    
    player.sendMessage('\u00a77\u00a7lTitan form ended...');
    
    // Remove titan from map
    playerTitanState.delete(playerId);
    
    // Kill titan entity
    if (titan && titan.isValid()) {
      player.dimension.runCommandAsync(`particle minecraft:explosion_particle ~~5~`);
      player.dimension.runCommandAsync(`playsound mob.wither.hurt @a ~~~ 1.5 1.2`);
      titan.kill();
    }
    
  } catch (error) {
    console.warn(`End form error: ${error}`);
  }
}

// Prevent dropping the ring
world.beforeEvents.itemDropper.subscribe((event) => {
  if (event.itemStack.typeId === TITAN_RING_ID) {
    event.cancel = true;
  }
});

console.log('\u00a7a[AOT MOD v2.0] Successfully loaded!');
