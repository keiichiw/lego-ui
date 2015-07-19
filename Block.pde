class Block {
  int y;
  int p, left, right;
  boolean isFloating;

  Block(int x, int y) {
    this.y = y;
    this.left = this.right = this.p = x;
    this.isFloating = true;
  }

  int getSize() {
    return this.right - this.left + 1;
  }

  boolean connect(Block obj) {
    if (abs(this.y - obj.y) != 1)
      return false;
    if (this.right < obj.left || obj.right < this.left)
      return false;
    return true;
  }

  void draw(boolean[][] b) {
    if (this.isFloating) {
      draw_rgb(100, 100, 100, b);
    } else {
      draw_rgb(0, 0, 255, b);
    }
  }

  void draw_rgb(int r, int g, int b, boolean[][] board) {
    int ry = this.y * C_HEIGHT;
    int rx = this.left * C_WIDTH;
    int sz = this.getSize();
    fill(r, g, b);
    stroke(0);
    strokeWeight(3);
    rect(rx, ry, C_WIDTH * sz, C_HEIGHT);

    // draw studs
    if (y == 0) return;
    int sy = this.y * C_HEIGHT - STUD_H;
    for (int x = this.left; x <= this.right; ++x) {
      if (!board[y-1][x]) {
        int sx = x * C_WIDTH + C_WIDTH / 2  - STUD_W / 2;
        rect(sx, sy, STUD_W, STUD_H);
      }
    }
  }

}
