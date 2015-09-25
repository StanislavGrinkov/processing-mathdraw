import processing.opengl.*;
import java.awt.event.KeyEvent;
import geomerative.*;

ParametricSystemController controller = new ParametricSystemController();

void setup() {
  size(1000, 1000, P3D);
  smooth(8);
  hint(ENABLE_KEY_REPEAT);
  frameRate(50);
  RG.init(this);
  controller.setState(SystemState.EDIT_PARAMS);
}

void draw() {
  controller.drawMe(this.g);
}

void keyPressed() {
  controller.processKeys();
  redraw();
}