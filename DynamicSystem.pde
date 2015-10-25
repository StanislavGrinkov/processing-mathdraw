enum SystemState {
  DEFAULT,
  EDIT_PARAMS,
  EDIT_COLOR
}

abstract class DynamicSystem {
  protected boolean isSelected;
  protected String name;
  protected BaseColor currentColor;
  
  public abstract void drawMe(PGraphics pg);
  
  public abstract void processDefaultKeys();
  public abstract void processEditColorKeys();
  public abstract void processEditParamKeys();
  
  public abstract int drawHelpDefault(int y);
  public abstract int drawHelpEditParams(int y);
  public abstract int drawHelpEditColor(int y);
  
  public abstract RGroup getSvg(boolean emulateBallpen);
  
  public abstract DynamicSystem clone();
  
  public void drawHelp(SystemState state) {
    textSize(14);
    fill(0); // depends on bg color
    int y = 20;
    if (state == SystemState.DEFAULT) {
      drawHelpDefault(y);
      return;
    }
    if (state == SystemState.EDIT_PARAMS) {
      drawHelpEditParams(y);
      return;
    }
    if (state == SystemState.EDIT_COLOR) {
      drawHelpEditColor(y);
      return;
    }
  };
  
  public void processKeys(SystemState state) {
    if (state == SystemState.DEFAULT) {
      processDefaultKeys();
      return;
    }
    if (state == SystemState.EDIT_PARAMS) {
      processEditParamKeys();
      return;
    }
    if (state == SystemState.EDIT_COLOR) {
      processEditColorKeys();
      return;
    }
  };

  protected String getFileName(String prefix, String ext) {
    int y = year();
    String m = nf(month(), 2);
    String d = nf(day(), 2);
    String h = nf(hour(), 2);
    String mm = nf(minute(), 2);
    String s = nf(second(), 2);
    return String.format("%s-%d-%s-%sT%s%s%s.%s", prefix, y, m, d, h, mm, s, ext);
  }
  
  public void setSelected(boolean state) { isSelected = state;};
  public boolean getSelected() {return isSelected; };
}