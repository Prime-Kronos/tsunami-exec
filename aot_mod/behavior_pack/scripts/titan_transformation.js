import { world, system } from '@minecraft/server';
import { ActionFormData } from '@minecraft/server-ui';

const TITAN_RING_ID = 'aot:titan_ring';
const TITAN_ENTITY = 'aot:attacking_titan';
const TRANSFORMATION_DURATION = 40; // ticks
const TITAN_DURATION = 300; // ticks = 15 seconds

let playerTitanState = new Map();

// Main transformation system
world.afterEvents.itemUse.subscribe((event) => {
  const player = event.source;
  const item = event.itemStack;
  
  if (item.typeId === TITAN_RING_ID && !playerTitanState.has(player.name)) {
    startTitanTransformation(player);
  }
});

function startTitanTransformation(player) {
  const playerId = player.name;
  
  // Play transformation sounds and effects
  player.dimension.runCommandAsync(`playsound mob.titan.roar @s ~~~ 1 0`);
  player.dimension.runCommandAsync(`particle minecraft:enchantment_table_particle ~~~`);
  
  // Add transformation tags
  player.addTag('titan_transforming');
  playerTitanState.set(playerId, {
    isTransforming: true,
    startTime: system.currentTick
  });
  
  // Tell player
  player.sendMessage('\u00a7c\u00a7lTITAN TRANSFORMATION INITIATED!');
  
  // Schedule transformation completion
  system.runTimeout(() => {
    completeTitanTransformation(player);
  }, TRANSFORMATION_DURATION);
}

function completeTitanTransformation(player) {
  const playerId = player.name;
  
  try {
    // Get player position
    const pos = player.location;
    
    // Spawn giant titan entity
    const titan = player.dimension.spawnEntity(TITAN_ENTITY, {
      x: pos.x,
      y: pos.y,
      z: pos.z
    });
    
    // Link titan to player
    titan.addTag(`titan_owner_${playerId}`);
    player.addTag('is_titan');
    player.addTag('titan_active');
    
    // Add effects
    player.dimension.runCommandAsync(`particle minecraft:enchantment_table_particle ~~~`);
    player.dimension.runCommandAsync(`playsound mob.titan.roar @s ~~~ 1.2 0.8`);
    player.dimension.runCommandAsync(`effect @s strength 15 2`);
    player.dimension.runCommandAsync(`effect @s speed 15 1`);
    
    player.sendMessage('\u00a74\u00a7lTITAN FORM ACTIVATED!');
    player.sendMessage('\u00a77You have 15 seconds of power!');
    
    playerTitanState.set(playerId, {
      isTransforming: false,
      isTitan: true,
      startTime: system.currentTick,
      titanEntity: titan
    });
    
    // Remove titan form after duration
    system.runTimeout(() => {
      endTitanForm(player, titan);
    }, TITAN_DURATION);
    
  } catch (error) {
    console.warn(`Error in titan transformation: ${error}`);
    player.sendMessage('\u00a7cTransformation failed!');
  }
}

function endTitanForm(player, titan) {
  const playerId = player.name;
  
  try {
    player.removeTag('is_titan');
    player.removeTag('titan_active');
    player.removeTag('titan_transforming');
    
    // Remove effects
    player.dimension.runCommandAsync(`effect @s clear`);
    
    player.sendMessage('\u00a77Titan form ended...');
    
    // Remove titan state
    playerTitanState.delete(playerId);
    
    // Kill titan entity if exists
    if (titan && titan.isValid()) {
      titan.kill();
    }
    
  } catch (error) {
    console.warn(`Error ending titan form: ${error}`);
  }
}

// Prevent item from being dropped
world.beforeEvents.itemDropper.subscribe((event) => {
  if (event.itemStack.typeId === TITAN_RING_ID) {
    event.cancel = true;
  }
});

console.log('\u00a7a[AOT MOD] Titan Transformation System Loaded!');
