import java.util.Arrays;

class Board {
  int[] useNum;

  boolean [][] board = new boolean[ROWS][COLS];

  Mode mode;
  Block sBlock;
  ArrayList<Block> blocks = new ArrayList<Block>();

  int ground;

  Board() {
    init();
  }

  void init() {
    mode = Mode.WAITING;
    ground = 0;
    useNum = new int[4];
    blocks.clear();

    for (int i = 0; i < ROWS; ++i) {
      for (int j = 0; j < COLS; ++j) {
        board[i][j] = false;
      }
    }
  }

  void setGround() {
    ground = 0;
    for (int i = 0; i < blocks.size(); ++i) {
      ground = max(ground, blocks.get(i).y);
    }
  }


  void floatingCheck() {
    int n = blocks.size();
    ArrayList<ArrayList<Integer>> adjs = new ArrayList<ArrayList<Integer>>();

    for (int i = 0; i < n; ++i) {
      adjs.add(new ArrayList<Integer>());
    }

    for (int i = 0; i < n - 1; ++i) {
      for (int j = i + 1; j < n; ++j) {
        if (blocks.get(i).connect(blocks.get(j))) {
          adjs.get(i).add(j);
          adjs.get(j).add(i);
        }
      }
    }

    // check blocks placed on the ground
    setGround();

    for (int i = 0; i < n; ++i) {
      blocks.get(i).isFloating = (blocks.get(i).y != ground);
    }

    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < n; ++j) {
        if (!blocks.get(j).isFloating)
          continue;
        for (int k = 0; k < adjs.get(j).size(); ++k) {
          int idx = adjs.get(j).get(k);
          if (!blocks.get(idx).isFloating) {
            blocks.get(j).isFloating = false;
            break;
          }
        }
      }
    }

  }


  void drawBoard() {

    // draw Grid
    for (int i = 0; i < ROWS; ++i) {
      for (int j = 0; j < COLS; ++j) {
        int y = i*C_HEIGHT;
        int x = j*C_WIDTH;
        fill(255);
        stroke(0);
        strokeWeight(1);
        rect(x, y, C_WIDTH, C_HEIGHT);
      }
    }


    // draw Ground
    if (ground == ROWS - 1) {
      fill(0, 128, 0);
      strokeWeight(0);
      rect(0, HEIGHT - 5, WIDTH, 5);
    } else if (ground != 0) {
      stroke(0, 128, 0);
      strokeWeight(5);
      int g_line = ground + 1;
      line(0, g_line * C_HEIGHT, WIDTH, g_line * C_HEIGHT);
    }

    // block floating check
    floatingCheck();

    // draw Blocks
    for (int i = 0; i < blocks.size(); ++i) {
      Block b = blocks.get(i);
      b.draw(board);
      for (int x=b.left; x<=b.right; ++x) {
        board[b.y][x] = true;
      }
    }

    // draw incomplete block
    if (sBlock != null) {
      int col = 256;
      int sz = sBlock.getSize();
      for (int i = 0; i < 4; ++i) {
        int r = blockNum[i] - useNum[i];
        if (sz == blockSize[i] && r > 0) {
          col = 100;
        }
      }
      sBlock.draw_rgb(col, col, col, board);
    }
  }

  boolean valid(int x, int y) {
    return
      0 <= x && x < COLS &&
      0 <= y && y < ROWS;
  }


  void getPoint() {
    int x = mouseX / C_WIDTH;
    int y = mouseY / C_HEIGHT;

    if (valid(x, y) && !board[y][x]) {
      mode = Mode.CREATING;
      sBlock = new Block(x, y);
    }
  }

  boolean overlap(int l, int r, int y) {
    for (int i=l; i <= r; ++i) {
      if (board[y][i]) {
        return true;
      }
    }
    return false;
  }

  void creating() {
    if (mousePressed && mouseButton == LEFT) { // writing
      int x = mouseX / C_WIDTH;
      int y = mouseY / C_HEIGHT;

      if (!valid(x, y)) {
        return;
      }
      if (y == sBlock.y) {
        int left = min(sBlock.p, x);
        int right= max(sBlock.p, x);

        if (!overlap(left, right, y)) {
          sBlock.left  = left;
          sBlock.right = right;
        }
      }
      return;
    }

    Block b = sBlock;
    sBlock = null;
    mode = Mode.WAITING;
    int sz = b.getSize();

    for (int i = 0; i < blockSize.length; ++i) {
      if (sz == blockSize[i] && useNum[i] < blockNum[i]) {
        blocks.add(b);
        return;
      }
    }
  }


  void countBlocks() {
    useNum = new int[4];

    for (Block b: blocks) {
      int sz = b.getSize();
      for (int i = 0; i < 4; ++i) {
        if (blockSize[i] == sz) {
          useNum[i] += 1;
          continue;
        }
      }
    }
  }

  void drawTextField() {

    // draw Field
    fill(200);
    stroke(0);
    strokeWeight(0);
    rect(WIDTH, 0, MENU_WIDTH, HEIGHT);

    // count Blocks
    countBlocks();

    fill(#ffffff, 0);
    stroke(255, 0, 0);
    strokeWeight(2);
    int sz = (sBlock != null) ? sBlock.getSize() : -1;
    for (int i = 0; i < 4; ++i) {
      if (sz == blockSize[i]) {
        rect(WIDTH + 18, 18 + i * 40, 118, 24);
      }
    }

    // show remains
    PFont font = createFont("Takao",20,true);
    textFont(font);
    for (int i = 0; i < 4; ++i) {
      int r = blockNum[i] - useNum[i];
      fill(0 < r ? 0 : 255);
      text("1x"+ blockSize[i] +
           ": 残り" + r + "個",
           WIDTH + 20, 20 + i * 40, 200, 40);
    }
  }

  void removeBlock() {
    int x = mouseX / C_WIDTH;
    int y = mouseY / C_HEIGHT;
    if (!valid(x, y)) return;
    if (!board[y][x]) return;

    for (int i=0; i < blocks.size(); ++i) {
      Block b = blocks.get(i);
      if (b.y == y && b.left <= x && x <= b.right) {

        for (int j=b.left; j <= b.right; ++j) {
          board[y][j] = false;
        }
        blocks.remove(i);
        return;
      }
    }
  }

}
