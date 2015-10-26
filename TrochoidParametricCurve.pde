import geomerative.*;

class TrochoidParametricCurve extends DynamicSystem {
  
  int colorFuncIndex = 0;
  
  BaseColor[] colorFunctions = {
    new Gradient()    
  };
  
  final class PathPoint {
    public float x;
    public float y;
    
    public PathPoint(float x, float y) {
      this.x = x;
      this.y = y;
    }
  }

  ParametricSystemController controller;
  
  ArrayList<PathPoint> pathPoints = new ArrayList<PathPoint>();
  StepFuncBase[] stepFunctions = {
    new StepFuncEqualStep(0.1f, -5f, 5f, 0.01f, 0.001f),
    new StepFuncDivisor(1.1f, 1.01f, 2.1f, 0.01f, 0.001f),
    //new StepFuncSinStep(0, -180, 180, 2),
  };
  int stepFuncIndex = 0;
  StepFuncBase currentStepFunc = stepFunctions[stepFuncIndex];
  
  boolean isEpitrochoid = false;
  
  float a = 5;
  float b = 4.5;
  float h = 5;
  float zoom = 50;
  int rev = 9;
  float rotationAngle = 0;
  int iterations = 45; 
  float iterationAngle = 0;
  float center_x = 0;
  float center_y = 0;
  
  boolean applyStepFuncToH = true;
  boolean applyStepFuncToZoom = false;
  
  public TrochoidParametricCurve(ParametricSystemController controller) {
    name = "PC-" + Math.round(Math.random()*5000);
    this.controller = controller;
    currentColor = colorFunctions[colorFuncIndex];
  }
  
  @Override
  public DynamicSystem clone() {
    TrochoidParametricCurve pc = new TrochoidParametricCurve(this.controller);
    pc.a = this.a;
    pc.b = this.b;
    pc.h = this.h;
    pc.zoom = this.zoom;
    pc.rev = this.rev;
    pc.rotationAngle = this.rotationAngle;
    pc.iterationAngle = this.iterationAngle;
    pc.iterations = this.iterations;
    pc.center_x = this.center_x;
    pc.center_y = this.center_y;
    pc.applyStepFuncToH = this.applyStepFuncToH;
    pc.applyStepFuncToZoom = this.applyStepFuncToZoom;
    pc.isEpitrochoid = this.isEpitrochoid;
    for (int i = 0; i < stepFunctions.length; ++i) {
      pc.stepFunctions[i] = this.stepFunctions[i].clone();
    }
    pc.stepFuncIndex = this.stepFuncIndex;
    pc.currentStepFunc = pc.stepFunctions[this.stepFuncIndex];
    
    for (int i = 0; i < colorFunctions.length; ++i) {
      pc.colorFunctions[i] = this.colorFunctions[i].clone();
    }
    pc.currentColor = pc.colorFunctions[this.colorFuncIndex];
    return pc;
  }
  
  public void calculatePath(float h_, float factor_)
  {
    if (isEpitrochoid)
        calculateEpitrochoidPath(h_, factor_);
      else
        calculateHypotrochoidPath(h_, factor_);
  }
  
  private void calculateHypotrochoidPath(float h, float factor) {
    float a_ = a * factor;
    float b_ = b * factor;
    float h_ = h * factor;
    float r = a_ - b_;
    float rb = r / b_;
    pathPoints.clear();
    for (int t = 0; t < rev*360 + 2; ++t) {
      float rt = radians(t);
      float x = (r * cos(rt) + h_ * cos(rb * rt));
      float y = (r * sin(rt) - h_ * sin(rb * rt));
      pathPoints.add(new PathPoint(x, y));
    }    
  }
  
  private void calculateEpitrochoidPath(float h, float factor) {
    float a_ = a * factor;
    float b_ = b * factor;
    float h_ = h * factor;
    float r = a_ - b_;
    float rb = r / b_;
    pathPoints.clear();
    for (int t = 0; t < rev*360 + 2; ++t) {
      float rt = radians(t);
      float x = (r * cos(rt) - h_ * cos(rb * rt));
      float y = (r * sin(rt) - h_ * sin(rb * rt));
      pathPoints.add(new PathPoint(x, y));
    }    
  }

  @Override
  public RGroup getSvg() {
    colorMode(RGB, 255);
    RGroup group = new RGroup();
    float h_ = h;
    float zoom_ = zoom;
    float colorStep = 1.0f / iterations;
    for (int i = 0; i < iterations; ++i) {
      calculatePath(h_, zoom_);
      
      PathPoint p = pathPoints.get(0);
      RPath path = new RPath(p.x, p.y);
      for (int t = 1; t < pathPoints.size(); ++t) {
        p = pathPoints.get(t);
        path.addLineTo(p.x, p.y);
      }
      
      if (applyStepFuncToZoom)
        zoom_ = currentStepFunc.next(zoom_);        
      if (applyStepFuncToH)
        h_ = currentStepFunc.next(h_);
        
      RShape shape = path.toShape();
      shape.setStroke(currentColor.getColor(colorStep * i));
      shape.setFill(false);
      shape.translate(center_x*i, center_y*i);
      shape.rotate(radians(iterationAngle * i), shape.getCenter());
      group.addElement(shape);
    }
    group.rotate(radians(rotationAngle), group.getCenter());
    return group;
  }
  
  @Override
  public void drawMe(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(width / 2, height / 2);
    pg.rotate(radians(rotationAngle));
    pg.noFill();

    pg.strokeWeight(1);
    float h_ = h;
    float zoom_ = zoom;
    float colorStep = 1.0f / iterations;
    for (int i = 0; i < iterations; ++i) {
      calculatePath(h_, zoom_);
      color vertexColor = isSelected ? #000000 : currentColor.getColor(colorStep * i); //float lerpStep = 1.0 / pathPoints.size(); //colorizer.getColor(t*lerpStep);
      
      pg.beginShape();
      pg.stroke(vertexColor);
      for (int t = 0; t < pathPoints.size(); ++t) {
        PathPoint p = pathPoints.get(t);
        pg.vertex(p.x, p.y);
      }
      pg.endShape();
      
      if (applyStepFuncToZoom)
        zoom_ = currentStepFunc.next(zoom_);        
      if (applyStepFuncToH)
        h_ = currentStepFunc.next(h_);
      pg.rotate(radians(iterationAngle));
      pg.translate(center_x, center_y);
    }
    pg.popMatrix();
  }
  
  @Override
  public void processDefaultKeys() {
  }
  
  @Override
  public void processEditColorKeys() {
    currentColor.processKeys();
    switch (key) {
      case ',':
        --colorFuncIndex;
        if (colorFuncIndex < 0)
          colorFuncIndex = colorFunctions.length - 1;
        currentColor = colorFunctions[colorFuncIndex];
        break;
      case '.':
        ++colorFuncIndex;
        if (colorFuncIndex > colorFunctions.length - 1)
          colorFuncIndex = 0;
        currentColor = colorFunctions[colorFuncIndex];
        break;
    }
    switch (keyCode) {
      case KeyEvent.VK_BACK_SPACE:
        controller.setState(SystemState.EDIT_PARAMS);
        break;
    }
  }
  
  @Override
  public void processEditParamKeys() {
    float r_step = 0.5f;
    float h_step = 0.5f;
    float zoom_step = 1f;
    float d_moveStep = 0.5f;
    float stepAngle = 0.1f;
    currentStepFunc.processKeys();
    
    isSelected = false;
    
    switch(keyCode) {
      case KeyEvent.VK_UP:
        center_y -= d_moveStep;
        break;
      case KeyEvent.VK_DOWN:
        center_y += d_moveStep;
        break;
      case KeyEvent.VK_LEFT:
        center_x -= d_moveStep;
        break;
      case KeyEvent.VK_RIGHT:
        center_x += d_moveStep;
        break;
    }
    switch(key) {
      case 'a':
        a += r_step;
        if (a == 0.0f || b == a)
          a += r_step;
        break;
      case 'A':
        a -= r_step;
        if (a == 0.0f || b == a)
          a -= r_step;
        break;
      case 'b':
        b += r_step;
        if (b == 0.0f || b == a)
          b += r_step;
        break;
      case 'B':
        b -= r_step;
        if (b == 0.0f || b == a)
          b -= r_step;
        break;
      case 'h':
        h += h_step;
        break;
      case 'H':
        h -= h_step;
        break;
      case 'r':
        ++rev;
        break;
      case 'R':
        if (rev > 1)
          --rev;
        break;
      case 'z':
        zoom += zoom_step;
        break;
      case 'Z':
        zoom -= zoom_step;
        break;
      case 'g':
        ++rotationAngle;
        break;
      case 'G':
        --rotationAngle;
        break;
      case 'j':
        iterationAngle += stepAngle;
        if (iterationAngle > -0.0001 && iterationAngle < 0.0001)
        {
          iterationAngle = 0.0f;
        }
        break;
      case 'J':
        iterationAngle -= stepAngle;
        if (iterationAngle > -0.0001 && iterationAngle < 0.0001)
        {
          iterationAngle = 0.0f;
        }
        break;
      case 'i':
        ++iterations;
        break;
      case 'I':
      if (iterations > 1)
          --iterations;
        break;
      case 'e':
        controller.setState(SystemState.EDIT_COLOR);
        break;
      case ',':
        --stepFuncIndex;
        if (stepFuncIndex < 0)
          stepFuncIndex = stepFunctions.length - 1;
        currentStepFunc = stepFunctions[stepFuncIndex];
        break;
      case '.':
        ++stepFuncIndex;
        if (stepFuncIndex > stepFunctions.length - 1)
          stepFuncIndex = 0;
        currentStepFunc = stepFunctions[stepFuncIndex];
        break;
      case 'n':
        applyStepFuncToH = !applyStepFuncToH;
        break;
      case 'm':
        applyStepFuncToZoom = !applyStepFuncToZoom;
        break;
      case 't':
        isEpitrochoid = !isEpitrochoid;
        break;
    }
  }
  
  @Override
  public int drawHelpDefault(int y) {
    return y;
  }
  
  @Override
  public int drawHelpEditParams(int y) {
    text("use [ and ] to navigate between dynamic systems.", 10, y); y += Constants.lineDrawStep;
    text("name = " + name, 10, y); y += Constants.lineDrawStep;
    text((isEpitrochoid ? "Epitrochoid " : "Hypotrochoid") + " pattern (t to toggle)", 10, y); y += Constants.lineDrawStep;
    text("a = " + a + "  (+a, -A)", 10, y); y += Constants.lineDrawStep;
    text("b = " + b + "  (+b, -B)", 10, y); y += Constants.lineDrawStep;
    text("h = " + h + "  (+h, -H)", 10, y); y += Constants.lineDrawStep;
    text("rv = " + rev + "  (+r, -R)", 10, y); y += Constants.lineDrawStep;
    text("zoom = " + zoom + "  (+z, -Z)", 10, y); y += Constants.lineDrawStep;
    text("rotation = " + rotationAngle + "  (+g,-G)", 10, y); y += Constants.lineDrawStep;
    text("iteartions = " + iterations + "  (+i,-I)", 10, y); y += Constants.lineDrawStep;
    text("iteartionAngle = " + iterationAngle + "  (+j,-J)", 10, y); y += Constants.lineDrawStep;
    text("center_point = " + center_x + ", " + center_y + "  (arrows)", 10, y); y += Constants.lineDrawStep;
    text("", 10, y); y += Constants.lineDrawStep;
    text("Apply StepFunc To H = " + applyStepFuncToH + "  (n to toggle)", 10, y); y += Constants.lineDrawStep;
    text("Apply StepFunc To Z = " + applyStepFuncToZoom + "  (m to toggle)", 10, y); y += Constants.lineDrawStep;
    y = currentStepFunc.drawHelp(y);
    text("use < and > to change step function.", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > e < to enter color edit mode", 10, y); y += Constants.lineDrawStep;
    text("Press > backspace < to exit from Edit Parameters mode", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditColor(int y) {
    y = currentColor.drawHelp(y);
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("use < and > to change color function.", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > backspace < to exit from Edit Color mode", 10, y); y += Constants.lineDrawStep;
    return y;
  }
}