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



Board board;


void setup() {

  size(WIDTH + MENU_WIDTH, HEIGHT);
  board = new Board();

}


void draw() {

  switch (board.mode) {
  case WAITING:
    if (mousePressed) {
      if (mouseButton == LEFT) {
        board.getPoint();
      } else if (mouseButton == RIGHT){
        board.removeBlock();
      }
    }
    break;
  case CREATING:
    board.creating();
    break;
  default:
    //println("Error: "+mode);
  }

  board.drawTextField();
  board.drawBoard();
}
