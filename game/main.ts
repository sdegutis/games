import { Camera } from "./camera.js";
import { createCanvas, getPlayers, runGameLoop } from "./core.js";
import { loadCleanP8, MapTile } from "./pico8.js";

// sarahs idea:
//   i can place bombs that blow up certain bricks
//   jane can pick up keys that open doors
//   and sarah can push buttons that open bars

const WIDTH = 750;
const HEIGHT = 450;
const SCALE = 2;

const ctx = createCanvas(WIDTH, HEIGHT, SCALE);
const engine = runGameLoop();
const gamepadIndexes = await getPlayers(engine, ctx);

const game1 = await loadCleanP8('game/explore.p8');

const entities: Entity[] = [];
const players: Player[] = [];
const walls: Entity[] = [];
const keys: Key[] = [];

const MW = game1.map[0].length * 8;
const MH = game1.map.length * 8;

const camera = new Camera(MW, MH, WIDTH, HEIGHT, players);

class Entity {

  layer = 0;

  constructor(
    public x: number,
    public y: number,
    public image: OffscreenCanvas,
  ) { }

  draw(ctx: CanvasRenderingContext2D) {
    ctx.drawImage(this.image, Math.round(this.x), Math.round(this.y));
  }

}

class Player {

  gamepadIndex = gamepadIndexes.shift()!;
  get gamepad() { return navigator.getGamepads()[this.gamepadIndex]; }

  constructor(public entity: Entity) { }

  update() {
    if (!this.gamepad) return;
    const [x1, y1] = this.gamepad.axes;

    const x = this.entity.x + x1;
    if (!this.hitWall(x, this.entity.y)) {
      this.entity.x = x;
      camera.update();
    }

    const y = this.entity.y + y1;
    if (!this.hitWall(this.entity.x, y)) {
      this.entity.y = y;
      camera.update();
    }

    const key = this.hitKey(this.entity.x, this.entity.y);
    if (key) {
      const keyIndex = keys.indexOf(key);
      keys.splice(keyIndex, 1);

      const eIndex = entities.indexOf(key.entity);
      entities.splice(eIndex, 1);

      this.gamepad.vibrationActuator.playEffect("dual-rumble", {
        startDelay: 0,
        duration: 100,
        weakMagnitude: 1,
        strongMagnitude: 1,
      });
    }
  }

  hitWall(x: number, y: number) {
    for (const wall of walls) {
      if (
        x + 8 >= wall.x &&
        y + 8 >= wall.y &&
        x < wall.x + 8 &&
        y < wall.y + 8
      ) return true;
    }
    return false;
  }

  hitKey(x: number, y: number) {
    for (const key of keys) {
      if (
        x + 8 >= key.x &&
        y + 8 >= key.y &&
        x < key.x + 8 &&
        y < key.y + 8
      ) return key;
    }
    return null;
  }

  // gamepad.vibrationActuator.reset();
  // if (gamepad.buttons[ZR].value || gamepad.buttons[ZL].value) {

  // }

}

class Key {

  x; y;

  constructor(public entity: Entity) {
    this.x = entity.x;
    this.y = entity.y;
  }

  update(t: number) {
    const ms = 1000;
    this.entity.y = this.y + +Math.cos(((t % ms) / ms) * (Math.PI * 2)) * 2;
    this.entity.x = this.x + -Math.sin(((t % ms) / ms) * (Math.PI * 2)) * 2;
  }

}

function createEntity(tile: MapTile, x: number, y: number) {
  const entity = new Entity(x * 8, y * 8, tile.sprite.image);
  entities.push(entity);

  if (tile.sprite.flags.GREEN) {
    const player = new Player(entity);
    entity.layer = 2;
    players.push(player);
    createEntity(game1.map[y][x - 1], x, y);
  }
  else if (tile.sprite.flags.RED) {
    walls.push(entity);
  }
  else if (tile.sprite.flags.YELLOW) {
    const key = new Key(entity);
    entity.layer = 1;
    keys.push(key);
    createEntity(game1.map[y][x - 1], x, y);
  }
}

for (let y = 0; y < 64; y++) {
  for (let x = 0; x < 128; x++) {
    createEntity(game1.map[y][x], x, y);
  }
}

entities.sort((a, b) => {
  if (a.layer > b.layer) return 1;
  if (a.layer < b.layer) return -1;
  return 0;
});

camera.update();

engine.update = (t) => {
  for (const player of players) {
    player.update();
  }

  for (const key of keys) {
    key.update(t);
  }

  ctx.reset();
  ctx.translate(camera.mx, camera.my);

  for (const e of entities) {
    e.draw(ctx);
  }
};
