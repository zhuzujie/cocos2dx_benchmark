
class Game {
    constructor() {
        console.log('[Game] create instance');

        var config = {width: 640, height: 960, policy: 'FIXED_WIDTH'};
        var director = new Director(config);
        director.start();
        this.director = director;

        this.countLabel = document.createElement('div');
        this.countLabel.innerHTML = '0 stars';
        this.countLabel.style.cssText = 'position:absolute;top:2px;left:90px;z-index:10000;font:bold 9px Helvetica,Arial,sans-serif;color:red;';
        document.body.appendChild(this.countLabel);

        var self = this;
        document.body.style.cssText = 'cursor: pointer;';
        document.body.addEventListener('touchstart', function(event) {
            self.addStars(self.starsCountOffset);
        }, false );
        document.body.addEventListener('click', function(event) {
            self.addStars(self.starsCountOffset);
        }, false );
    }

    start() {
        console.log('[Game] start');

        this.starTexture = PIXI.Texture.fromImage('res/star.png');
        this.scene = new PIXI.Container();
        var self = this;
        this.scene.update = function(dt) {
            self.update(dt);
        }

        this.director.runWithScene(this.scene);

        this.starsLayer = new PIXI.Container();
        this.scene.addChild(this.starsLayer);

        this.offsetCount = 60;
        this.offsets = [];
        for (var i = 0; i < 60; i++) {
            this.offsets[i] = {
                x: Math.sin(i * 6 * Math.PI / 180) * 4,
                y: Math.cos(i * 6 * Math.PI / 180) * 4
            };
        }

        this.starsCountOffset = 1000;
        this.stars = [];

        self.addStars(self.starsCountOffset);
    }

    addStars(count) {
        var size = this.director.size;
        for (var i = 0; i < count; i++) {
            var star = new PIXI.Sprite(this.starTexture);
            var pos = {
                x: Math.random() * (size.width - 32),
                y: Math.random() * (size.height - 32),
                i: Math.floor(Math.random() * this.offsetCount),
                o: Math.random(),
                oi: 1.0 / 60
            };
            star.position.set(pos.x + this.offsets[pos.i].x, pos.y + this.offsets[pos.i].y);
            star.alpha = pos.o;
            star.pos = pos;
            this.starsLayer.addChild(star);
            this.stars.push(star);
        }

        this.countLabel.innerHTML = this.stars.length.toString() + ' stars';
    }

    update(dt) {
        var count = this.stars.length;
        for (var i = 0; i < count; i++) {
            this.updateStar(this.stars[i]);
        }
    }

    updateStar(star) {
        var pos = star.pos;
        var offset = this.offsets[pos.i];

        pos.i++;
        pos.i %= this.offsetCount;
        pos.o += pos.oi;
        if (pos.o > 1) {
            pos.o = 1;
            pos.oi = -pos.oi;
        } else if (pos.o < 0) {
            pos.o = 0;
            pos.oi = -pos.oi;
        }

        star.position.set(pos.x + offset.x, pos.y + offset.y);
        star.alpha = pos.o;
    }
}

