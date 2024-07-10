import { Entity } from "./entity.js";

export class Bubble extends Entity {

  sitting = false;
  unsat = 0;

  aliveFor = 0;

  constructor(
    x: number,
    y: number,
    private openImage: OffscreenCanvas,
    public flatImage: OffscreenCanvas,
  ) {
    super(x, y, openImage);
    this.dead = true;
  }

  reset(x: number, y: number) {
    this.dead = false;

    this.x = x;
    this.y = y;

    this.aliveFor = 0;
    this.unsat = 0;
    this.sitting = false;
  }

  // override collideWith = (player: Entity, x: number, y: number): Interaction => {
  //   if (x) {
  //     this.x += x;
  //     return 'pass';
  //   }

  //   if (y < 0) {
  //     this.y -= 1;
  //     return 'pass';
  //   }
  //   else if (y > 0) {
  //     // player.y -= 1;
  //     this.sitting = true;
  //     this.unsat = 1;
  //     this.image = this.flatImage;
  //     return 'stop';
  //   }

  //   return 'pass';
  // };

  override update = (t: number) => {
    this.aliveFor++;

    if (!this.sitting) {
      const durationMs = 1000;
      const percent = ((t % durationMs) / durationMs);
      const percentOfCircle = percent * Math.PI * 2;
      const distance = .5;
      this.x = this.x + -Math.sin(percentOfCircle) * distance;

      if (this.unsat) {
        this.unsat++;
        if (this.unsat === 3) {
          this.image = this.openImage;
        }
        else if (this.unsat === 30) {
          this.dead = true;
        }
      }
    }

    this.y -= this.sitting ? -0.25 : 0.25;

    if (this.y < -8) {
      this.dead = true;
    }

    this.sitting = false;
  };

}
