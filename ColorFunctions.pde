abstract class BaseColor {
  public abstract color getColor(float t);
  public abstract void processKeys();
  public abstract int drawHelp(int y);
  public abstract BaseColor clone();
  public abstract JSONObject getJSON();
  public abstract void generateRandom(int count /*OfInnerStops*/);
}

class Gradient extends BaseColor
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public final class ColorPosition
  {
    public color value;
    public float position;
    public ColorPosition(color value, float pos) {
      this.position = pos;
      this.value = value;
    }
    
    public ColorPosition clone() {
      return new ColorPosition(this.value, this.position);
    }
    
    public JSONObject getJSON() {
      JSONObject json = new JSONObject();
      json.setInt(Constants.Value, value);
      json.setFloat(Constants.Position, position);
      return json;
    }
  } // ColorPosition
  
  
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  class ColorPositionComparator implements Comparator<ColorPosition>
  {
    @Override
    public int compare(ColorPosition f1, ColorPosition f2)
    {
      return Float.compare(f1.position, f2.position);
    }
  } // ColorPositionComparator

  
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public final class LinearColorStrip {
    Comparator<ColorPosition> currentComparator = new ColorPositionComparator();
    
    ArrayList<ColorPosition> colors = new ArrayList<ColorPosition>();
    int colorIndex = 0;
    
    private LinearColorStrip() {}

    public LinearColorStrip(color start) {
      this(start, start);
    }
    
    public LinearColorStrip(color start, color end) {
      colors.add(new ColorPosition(start, 0.0f));
      colors.add(new ColorPosition(end, 1.0f));
    }

    public LinearColorStrip(color[] colors, float[] positions) {
      if (colors.length == positions.length) {
        for (int i = 0; i < colors.length; ++i) {
          this.colors.add(new ColorPosition(colors[i], positions[i]));
        }
        sort();
      }
    }

    public JSONObject getJSON() {
      JSONObject json = new JSONObject();
      json.setString(Constants.ObjectType, this.getClass().getName());
      JSONArray strips = new JSONArray();
      for (int i = 0; i < colors.size(); ++i) {
        strips.setJSONObject(i, colors.get(i).getJSON());
      }
      json.setJSONArray(Constants.ColorPosition, strips);
      return json;
    }
    
    private void sort() {
      Collections.sort(this.colors, currentComparator);
    }
    
    public void reverse() {
      for (int i = 0; i < colors.size(); ++i) {
        colors.get(i).position = 1 - colors.get(i).position; 
      }
      sort();
    }
    
    public void invert() {
      for (int i = 0; i < colors.size(); ++i) {
        color c = colors.get(i).value;
        int r = 255 - (c >> 16 & 0xFF);
        int g = 255 - (c >> 8 & 0xFF);
        int b = 255 - (c & 0xFF);
        colors.get(i).value = color(r, g, b);
      }
    }
    
    public ColorPosition getColorPos(int index)
    {
      index = Math.max(index, 0);
      index = Math.min(index, colors.size() - 1);
      return colors.get(index);
    }
    
    public void nextColor() {
      ++colorIndex;
      if (colorIndex >= colors.size()) {
        colorIndex = 0;
      }
    }
    
    public void prevColor() {
      --colorIndex;
      if (colorIndex < 0) {
        colorIndex = colors.size() - 1;
      }
    }
    
    public boolean isEdgeStops() {
      return colorIndex == 0 || colorIndex == colors.size() - 1;
    }
    
    public void adjustColorPosition(float delta)
    {
      if (isEdgeStops()) {
        return;
      }
      float p = colors.get(colorIndex).position;
      p += delta;
      p = Math.max(p, 0.01);
      p = Math.min(p, 0.99);
      colors.get(colorIndex).position = p;
      sort();
    }
    
    private int drawGradientColors(int y) {
      y -= 10;
      int w = 980;
      float step = 1.0f / w;
      for (int i = 0; i < w; ++i) {
        fill(getAt(i*step));
        noStroke();
        rect(10 +i, y, 1, 15);
      }
      
      y += 15;
      for (int i = 0; i < colors.size(); ++i) {
        color c = colors.get(i).value;
        float p = colors.get(i).position;
        
        fill(c);
        noStroke();
        if (i == colorIndex) {
          stroke(0);
          strokeWeight(1.5f);
        }
        float x = w * p + 10;
        x= Math.min(x, 985);
        rect(x, y, 5, 15);
      }
      return y + 30;
    }
    
    public color getAt(float t) {
      color start = 0;
      color end = 255;
      t = Math.max(t, 0.00001f);
      t = Math.min(t, 0.9999f);
      
      switch (colors.size()) {
        case 0:
          return color(0);
        case 1:
          return colors.get(0).value;
        case 2:
          start = colors.get(0).value;
          end = colors.get(1).value;
          break;
        default:
          for (int i = 1; i < colors.size(); ++i) {
            ColorPosition current = colors.get(i - 1);
            ColorPosition next = colors.get(i);
            if (t >= current.position && t < next.position) {
              start = current.value;
              end = next.value;
              float diff = next.position - current.position;
              t = 1 - ((next.position - t) / diff);
              break;
            }
          }
          break;
      }
      return lerpColor(start, end, t); // can be changed in future to sin-lerp, spline-lerp , etc http://paulbourke.net/miscellaneous/interpolation/
    }
    
    public LinearColorStrip clone() {
      LinearColorStrip clone = new LinearColorStrip(); //<>//
      for (ColorPosition cp : colors) {
        clone.colors.add(cp.clone());
      }
      return clone;
    }
    
    public void insertColorStop() {
      if (colorIndex == colors.size() - 1) {
        return;
      }
      float p = colors.get(colorIndex).position;
      float p1 = colors.get(colorIndex + 1).position;
      float f = p + (p1 - p) / 2.0f;
      colors.add(new ColorPosition(getAt(f), f));
      sort();
      ++colorIndex;
    }
    
    public void insertColorStop(ColorPosition cp) {
      colors.add(cp);
      sort();
    }
    
    public void deleteColorStop() {
      if (isEdgeStops() || colors.size() == 2) {
        return;
      }
      colors.remove(colorIndex);
    }
    
    public void adjustRGB(int deltaR, int deltaG, int deltaB) {
      color c = colors.get(colorIndex).value;
      int r = (c >> 16 & 0xFF) + deltaR;
      int g = (c >> 8 & 0xFF)  + deltaG;
      int b = (c & 0xFF) + deltaB;
      colors.get(colorIndex).value = color(r, g, b);
    }
    
    public void adjustHSV(int deltaH, int deltaS, int deltaV) {
      colorMode(HSB, 255);
      color c = colors.get(colorIndex).value;
      float h = hue(c) + deltaH;
      float s = saturation(c) + deltaS;
      float b = brightness(c) + deltaV;
      colors.get(colorIndex).value = color(h, s, b);
      colorMode(RGB, 255);
    }
    
    public String getColorAsText() {
      return "#" + hex(colors.get(colorIndex).value, 6) + " <- " + colors.get(colorIndex).position;
    }
    
    public void generateRandom(int count /*OfInnerStops*/) {
      int totalStops = count + 2;
      colors.clear();
      for (int i = 0; i < totalStops; ++i) {
        int r = (int)(Math.random()*255);
        int g = (int)(Math.random()*255);
        int b = (int)(Math.random()*255);
        float p = (float)Math.random() - 0.1;
        p = Math.max(p, 0.01);
        p = Math.min(p, 0.99);
        p = i == 0 ? 0.0: p;
        p = i == (totalStops - 1) ? 1.0: p;
        colors.add(new ColorPosition(color(r, g, b), p));
        colorIndex = 0;
      }
      sort();
    }
  } // LinearColorStrip

  LinearColorStrip current = new LinearColorStrip(new color[] {#FF0000, #00FF00, #0000FF}, new float[] {0.0f, 0.5f, 1.0f});
  
  int d = 8;
  
  @Override
  public JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setString(Constants.ObjectType, this.getClass().getName());
    json.setJSONObject(Constants.LinearColorStrip, current.getJSON());
    return json;
  }
  
  @Override
  public color getColor(float t) {
    return current.getAt(t);
  }

  @Override
  public void processKeys() {
    switch(keyCode) {
      case KeyEvent.VK_NUMPAD7:
        current.insertColorStop();
        break;
      case KeyEvent.VK_NUMPAD9:
        current.deleteColorStop();
        break;
      case KeyEvent.VK_NUMPAD4:  
      case LEFT:
        current.prevColor();
        break;
      case KeyEvent.VK_NUMPAD6:
      case RIGHT:
        current.nextColor();
        break;
      case KeyEvent.VK_NUMPAD1:
        current.adjustColorPosition(-0.01);
        break;  
      case KeyEvent.VK_NUMPAD3:
        current.adjustColorPosition(0.01);
        break;
    }
    switch(key) {
     case 'r':
       current.adjustRGB(d, 0, 0);
       break;
     case 'R':
       current.adjustRGB(-d, 0, 0);
       break;
     case 'g':
       current.adjustRGB(0, d, 0);
       break;
     case 'G':
       current.adjustRGB(0, -d, 0);
       break;
     case 'b':
       current.adjustRGB(0, 0, d);
       break;
     case 'B':
       current.adjustRGB(0, 0, -d);
       break;
     case 'h':
       current.adjustHSV(d, 0, 0);
       break;
     case 'H':
       current.adjustHSV(-d, 0, 0);
       break;
     case 's':
       current.adjustHSV(0, d, 0);
       break;
     case 'S':
       current.adjustHSV(0, -d, 0);
       break;
     case 'v':
       current.adjustHSV(0, 0, d);
       break;
     case 'V':
       current.adjustHSV(0, 0, -d);
       break;
     case 'd':
       d = d >> 2;
       d = d > 64 ? 64 : d;
       break;
     case 'D':
       d = d << 2;
       d = d < 2 ? 1 : d;
       break;
      case 'x':
        current.reverse();
        break;
      case 'c':
        current.invert();
        break;
    }
  }
 
  @Override
  public int drawHelp(int y) {
    y = current.drawGradientColors(y);
    text(current.getColorAsText() + "(rR, gG, bB; hH, sS, vV) / " + "Delta: " + d + " (+d; -D)", 10, y); y += Constants.lineDrawStep;
    text("", 10, y); y += Constants.lineDrawStep;
    text("Numpad > 7, 9 < to insert color stop after current or delete current color stop", 10, y); y += Constants.lineDrawStep;
    text("Numpad > 4, 6 < to select color stop", 10, y); y += Constants.lineDrawStep;
    text("Numpad > 1, 3 < to adjust color stop position", 10, y); y += Constants.lineDrawStep;
    text("Use 1-9 to generate N+2 color random gradient", 10, y); y += Constants.lineDrawStep;
    text("> x < to reverse gradient direction", 10, y); y += Constants.lineDrawStep;
    text("> c < to invert color value", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public void generateRandom(int count /*OfInnerStops*/) {
    current.generateRandom(count);
  }
  
  @Override
  public BaseColor clone() {
    Gradient g = new Gradient(); //<>//
    g.current = current.clone();
    return g;
  } 
}