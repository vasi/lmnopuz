function FocusBox(color, border, zindex) {
  var box = document.createElement('div');
  box.className = 'focusbox';
  box.style.zIndex = zindex;
  box.style.borderWidth = border + 'px';
  box.display = 'none';
  
  this.box = box;
  this.setColor(color);
  
  document.body.appendChild(this.box);
  
  this.x = this.y = this.w = this.h = 0;
  this.border = border;
};

FocusBox.prototype.setColor = function(color) {
  this.box.style.borderColor = color;
};

FocusBox.prototype.drawBox = function(x, y, w, h) {
  if (w == 0 && h == 0) {
    this.box.style.display = 'none';
  } else if (this.w == 0 && this.h == 0) {
    this.box.style.display = 'block';
  }
  
  this.box.style.left = (x - this.border / 2) + 'px';
  this.box.style.top = (y - this.border / 2) + 'px';
  this.box.style.width = (w - this.border) + 'px';
  this.box.style.height = (h - this.border) + 'px';
  
  this.x = x;
  this.y = y;
  this.w = w;
  this.h = h;
};

FocusBox.prototype.animate = function(x2, y2, w2, h2) {
  // Disable existing animation
  if (this.timer) {
    clearInterval(this.timer);
    this.timer = null;
  }
  
  var self = this;
  var interp = function(p1, p2) {
    var p = Math.round(p1 + (p2 - p1) / 2);
    if (p == p2 - 1 || p == p2 + 1)
      p = p2;
    return p;
  };
  this.timer = setInterval(function() {
    self.drawBox(interp(self.x, x2), interp(self.y, y2),
      interp(self.w, w2), interp(self.h, h2));
    if (self.x == x2 && self.y == y2 && self.w == w2 && self.h == h2) {
      clearInterval(self.timer);
      self.timer = null;
    }
  }, 20);
};

FocusBox.prototype.clearTimer = function() {
};

FocusBox.prototype.moveTo = function(x, y, w, h, animate) {
  if (animate) {
    this.animate(x, y, w, h);
  } else {
    this.drawBox(x, y, w, h);
  }
};
