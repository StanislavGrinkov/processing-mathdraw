//import java.awt.event.KeyEvent;

class ParametricSystemController extends DynamicSystem {
  
  ArrayList<DynamicSystem> dynamicSystems = new ArrayList<DynamicSystem>(); 
  DynamicSystem current = null;
  int index = 0;
  
  
  SystemState state = SystemState.DEFAULT;
  
  public ParametricSystemController() {
    current = new TrochoidParametricCurve(this);
    dynamicSystems.add(current);
    index = 0;
  }
  
  @Override
  public RGroup getSvg() {
    RGroup group = new RGroup();
    for (DynamicSystem curve: dynamicSystems) {
      group.addElement(curve.getSvg());
    }
    return group;
  }
  
  @Override
  public JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setBoolean(Constants.blackBackground, isNegative);
    JSONArray jsonDS = new JSONArray();
    for (int i = 0; i < dynamicSystems.size(); ++i) {
      jsonDS.setJSONObject(i, dynamicSystems.get(i).getJSON());
    }
    json.setJSONArray(Constants.DynamicSystems, jsonDS);
    return json;
  }
  
  int drawDynamicSystemsCount(int y) {
    textSize(14);
    String c = "[ ";
    String s = "  ";
    for (int i =0; i < dynamicSystems.size(); ++i) {
      c += i != index ? "*" : "_";
      s += i == index ? "V" : "_";
    }
    c += " ]";
    fill(!isNegative ? 0 : 255);
    text(c, 10, y);
    fill(#ff0000);
    text(s, 10, y); y += Constants.lineDrawStep;
    fill(!isNegative ? 0 : 255);
    return y;
  }

  @Override
  public DynamicSystem clone() {
    return null;
  }
  
  @Override
  public void drawMe(PGraphics pg) {
    pg.background(isNegative ? 0 : 255);
    pg.pushMatrix();
    for (DynamicSystem curve: dynamicSystems) {
      curve.drawMe(pg);
    }
    pg.popMatrix();
    drawHelp(state);
  }

  public void setState(SystemState state) {
    this.state = state;
    redraw();
  }
  
  public void processKeys() {
    this.processKeys(state);
  }

  
  @Override
  public void processDefaultKeys() {
    switch(key) {
      case 's':
        saveJson();
        savePreview();
        saveSvg();
        break;
      case 'e':
        state = SystemState.EDIT_PARAMS;
        current.setSelected(true);
        break;
    }
  }
  
  private void saveJson() {
    String fileName = "output/"+getFileName("json", "json");
    saveJSONObject(getJSON(), fileName);
  }
  
  private void saveSvg() {
    String fileName = "output/"+getFileName("vector", "svg");
    new RSVG().saveGroup(fileName, getSvg());
  }
  
  private void savePreview() {
    PGraphics pg = createGraphics(1000, 1000, P3D, null);
    pg.beginDraw();
    pg.smooth(8);
    pg.background(isNegative ? 0 : 255);
    for (DynamicSystem curve: dynamicSystems) {
      curve.drawMe(pg);
    }
    pg.endDraw();
    pg.save("output/"+getFileName("preview", "png"));
  }
  
  @Override
  public void processEditColorKeys() {
    current.processEditColorKeys();
  }
  
  @Override
  public void processEditParamKeys() {
    switch(keyCode) {
      case KeyEvent.VK_P:
        current.setSelected(!current.getSelected());
        return;
      case KeyEvent.VK_C:
        current = current.clone(); //<>//
        dynamicSystems.add(current);
        index = dynamicSystems.size() - 1;
        return;
      case KeyEvent.VK_INSERT:
        current = new TrochoidParametricCurve(this);
        dynamicSystems.add(current);
        index = dynamicSystems.size() - 1;
        break;
      case KeyEvent.VK_DELETE:
        if (dynamicSystems.size() == 1)
          break;
        dynamicSystems.remove(index);
        if (index > dynamicSystems.size() - 1)
          --index;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_CLOSE_BRACKET:
        ++index;
        if (index > dynamicSystems.size() - 1)
          index = 0;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_OPEN_BRACKET:
        --index;
        if (index < 0)
          index = dynamicSystems.size() - 1;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_BACK_SPACE:
        state = SystemState.DEFAULT;
        current.setSelected(false);
        return;
    }
    
    current.processEditParamKeys();
  }
  
  @Override
  public int drawHelpDefault(int y) {
    text("Press > e < to enter param edit mode", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > s < to  save SVG, render preview on 1000x1000 canvas and save parameters to txt file", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditParams(int y) {
    y = drawDynamicSystemsCount(y);
    y = current.drawHelpEditParams(y);
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > c < to clone current DynamicSystem", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditColor(int y) {
    y = current.drawHelpEditColor(y);
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    return y;
  }
}