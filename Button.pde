class Button {

  int x, y;
  int w, h;
  int font_size;
  String label;
  Button(int a, int b, int c, int d, int f, String s) {
    x = a; y = b;
    w = c; h = d;
    font_size = f;
    label = s;
  }

  void draw() {
    // reset button
    fill(255,255,200);
    stroke(0);
    strokeWeight(mouseOn() ? 2 : 1);
    rect(x, y, w, h);
    PFont font = createFont("Takao", font_size, true);
    textFont(font);
    fill(0);
    int l = label.length() * font_size;
    text(label, x + 4 + (w - l) / 2, y +  h - (h - font_size) / 2);
  }

  boolean mouseOn() {
    return
      x < mouseX && mouseX < x + w &&
      y < mouseY && mouseY < y + h;
  }

  boolean isPressed() {
    return mousePressed && mouseOn();
  }

}
