import java.util.Arrays;

final int HEIGHT = 480;
final int C_HEIGHT = 60;
final int ROWS   = HEIGHT / C_HEIGHT;

final int WIDTH  = 840;
final int C_WIDTH = 42;
final int COLS   = WIDTH / C_WIDTH;

final int STUD_H = C_HEIGHT / 5;
final int STUD_W = C_WIDTH  / 3;

final int MENU_WIDTH = 200;

final int[] blockSize = new int[] {2, 3, 4, 6};
final int[] blockNum  = new int[] {6, 6, 4, 4};
int[] useNum;

boolean [][] board = new boolean[ROWS][COLS];

Mode mode;
Block sBlock;
ArrayList<Block> blocks = new ArrayList<Block>();

class Block {
  int y;
  int left, right;
  Block(int x, int y) {
    this.y = y;
    this.left = this.right = x;
  }

  int getSize() {
    return this.right - this.left + 1;
  }

}


void setup() {

  size(WIDTH + MENU_WIDTH, HEIGHT);

  mode = Mode.WAITING;

  useNum = new int[4];

  for (int i = 0; i < ROWS; ++i) {
    for (int j = 0; j < COLS; ++j) {
      board[i][j] = false;
    }
  }

}

void drawBlock(Block block, int r, int g, int b) {
  int y = block.y * C_HEIGHT;
  int x = block.left * C_WIDTH;
  int sz = block.getSize();
  fill(r, g, b);
  stroke(0);
  strokeWeight(3);
  rect(x, y, C_WIDTH * sz, C_HEIGHT);
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


  // draw Grand
  fill(0, 128, 0);
  strokeWeight(0);
  rect(0, HEIGHT - STUD_H, WIDTH, STUD_H);

  // draw Blocks
  for (int i = 0; i < blocks.size(); ++i) {
    Block b = blocks.get(i);
    drawBlock(b, 0, 0, 255);
    for (int x=b.left; x<=b.right; ++x) {
      board[b.y][x] = true;
    }
  }
  // draw studs
  for (int i = 1; i < ROWS; ++i) {
    for (int j = 0; j < COLS; ++j) {
      if (board[i][j] && !board[i-1][j]) {
        int x = j * C_WIDTH + C_WIDTH / 2  - STUD_W / 2;
        int y = i * C_HEIGHT - STUD_H;
        rect(x, y, STUD_W, STUD_H);
      }
    }
  }


  // draw incomplete block
  if (sBlock != null) {
    drawBlock(sBlock, 128, 128, 128);
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
  for(int i=l; i <= r; ++i) {
    if(board[y][i]) {
      return true;
    }
  }
  return false;
}

boolean canPlace(Block b) {
  if (b.y == ROWS-1)
    return true;
  for (Block obj: blocks) {
    if (abs(b.y - obj.y) != 1)
      continue;
    if (!(b.right < obj.left || obj.right < b.left)) {
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
      int left = min(sBlock.left,  x);
      int right= max(sBlock.right, x);

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
      if (canPlace(b)) {
        blocks.add(b);
        return;
      }
    }
  }

  println("illegal size!!: " + sz);

}


void countBlocks() {
  useNum = new int[4];

  for(Block b: blocks) {
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
  // show remains
  fill(0);
  PFont font = createFont("Takao",20,true);
  textFont(font);
  for (int i=0; i < 4; ++i) {
    text("1x"+ blockSize[i] +
         ": 残り" + (blockNum[i] - useNum[i]) + "個",
         WIDTH + 20, 20 + i * 40, 200, 40);
  }

  // message box
  fill(255,255,200);
  stroke(200);
  strokeWeight(10);
  rect(WIDTH, HEIGHT/2, MENU_WIDTH, HEIGHT/2);

}

boolean canRemove(int x) {
  boolean[] ok = new boolean[blocks.size()];
  Arrays.fill(ok, false);

  for (int i = 0; i < ok.length; ++i) {
    if (i == x)
      continue;

    Block b = blocks.get(i);
    if (b.y == ROWS -1) {
      ok[i] = true;
    } else {
      for(int j = 0; j < blocks.size(); ++j) {
        Block obj = blocks.get(j);
        if (!ok[j] || abs(b.y - obj.y) != 1)
          continue;
        if (!(b.right < obj.left || obj.right < b.left)) {
          ok[i] = true;
          break;
        }
      }
    }
  }

  for (int i = 0; i < ok.length; ++i) {
    if (!ok[i] && i != x)
      return false;
  }
  return true;
}

void removeBlock() {
  int x = mouseX / C_WIDTH;
  int y = mouseY / C_HEIGHT;
  if(!valid(x, y)) return;
  if(!board[y][x]) return;

  for (int i=0; i < blocks.size(); ++i) {
    Block b = blocks.get(i);
    if(b.y == y && b.left <= x && x <= b.right) {

      if(!canRemove(i))
        return;

      for(int j=b.left; j <= b.right; ++j) {
        board[y][j] = false;
      }
      blocks.remove(i);
      return;
    }
  }

}

void draw() {

  switch (mode) {
  case WAITING:
    if (mousePressed) {
      if (mouseButton == LEFT) {
        getPoint();
      } else if (mouseButton == RIGHT){
        removeBlock();
      }
    }
    break;
  case CREATING:
    creating();
    break;
  default:
    println("Error: "+mode);
  }
  drawTextField();
  drawBoard();
}
