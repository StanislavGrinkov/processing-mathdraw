abstract class BaseColor {
  protected int presetIndex = 0;
  public abstract color getColor(float t);
  public abstract void processKeys();
  public abstract int drawHelp(int y);
  public abstract BaseColor clone();
}

class Gradient extends BaseColor
{
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
  }
  
  class ColorPositionComparator implements Comparator<ColorPosition>
  {
    @Override
    public int compare(ColorPosition f1, ColorPosition f2)
    {
      return Float.compare(f1.position, f2.position);
    }
  }

  public final class LinearColorStrip {
    Comparator<ColorPosition> currentComparator = new ColorPositionComparator();
    
    ArrayList<ColorPosition> colors = new ArrayList<ColorPosition>();
    boolean isReversed = false;
    
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
        Collections.sort(this.colors, currentComparator);
      }
    }
    
    public void reverse() {
      for (int i = 0; i < colors.size(); ++i) {
        colors.get(i).position = 1 - colors.get(i).position; 
      }
      Collections.sort(this.colors, currentComparator);
      isReversed = !isReversed;
    }
    
    public void invert() {
      for (int i = 0; i < colors.size(); ++i) {
        colors.get(i).value = invert(colors.get(i).value);
      }
    }
    
    private color invert(color c) {
      int r = 255 - (c >> 16 & 0xFF);
      int g = 255 - (c >> 8 & 0xFF);
      int b = 255 - (c & 0xFF);
      return color(r, g, b);
    }
    
    public color getAt(float t) {
      color start = 0;
      color end = 255;
      t = Math.max(t, 0.0f);
      t = Math.min(t, 1.0f);
      
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
      clone.isReversed = this.isReversed;
      return clone;
    }
  }

  LinearColorStrip[] presets = {
    new LinearColorStrip(new color[] {#FF0000, #00FF00, #0000FF}, new float[] {0.0f, 0.5f, 1.0f})
    , new LinearColorStrip(new color[] {#FF0000, #00FF00, #0000FF, #FF0000, #00FF00, #0000FF}, new float[] {0.0f, 0.1f, 0.4f, 0.5f, 0.9f, 1.0f})
  };
  
  LinearColorStrip current = presets[0];
  
  @Override
  public color getColor(float t) {
    return current.getAt(t);
  }

  @Override
  public void processKeys() {
    switch(key) {
      case 'r':
        current.reverse();
        break;
      case 'R':
        current.invert();
        break;
      case ']':
        ++presetIndex;
        if (presetIndex > presets.length - 1)
          presetIndex = 0;
        current = presets[presetIndex];
        break;
      case '[':
        --presetIndex;
        if (presetIndex < 0)
          presetIndex = presets.length - 1;
        current = presets[presetIndex];
        break;
    }
  }
  
  @Override
  public int drawHelp(int y) {
    //text("Red: " + r + " (+r; -R)", 10, y); y += Constants.lineDrawStep;
    //text("Green: " + g + " (+g; -G)", 10, y); y += Constants.lineDrawStep;
    //text("Blue: " + b + " (+b; -B)", 10, y); y += Constants.lineDrawStep;
    //text("Delta: " + d + " (+d; -D)", 10, y); y += Constants.lineDrawStep;   
    //text("Current: #" + hex(current, 6), 10, y); y += Constants.lineDrawStep;
    //fill(current);
    //rect(10, y - Constants.lineDrawStep + 2, 50, 15);
    //fill(0);
    //y += Constants.lineDrawStep + 5;
    text("> r < to reverse gradient direction", 10, y); y += Constants.lineDrawStep;
    text("> R < to invert color value", 10, y); y += Constants.lineDrawStep;
    text("use [ and ] to select preset gradients ", 10, y); y += Constants.lineDrawStep;
    //drawPresetColors(y - Constants.lineDrawStep + 2); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public BaseColor clone() {
    Gradient g = new Gradient(); //<>//
    g.current = current.clone();
    g.presetIndex = this.presetIndex;
    return g;
  }
  
}

  //@Override
  //public void processKeys() {
  //  println("solid colors->" + key);
  //  switch (key) {
  //    case 'r':
  //      r += d;
  //      r = r > 255 ? 255 : r;
  //      break;
  //    case 'R':
  //      r -= d;
  //      r = r < 0 ? 0 : r;
  //      break;
  //    case 'g':
  //      g += d;
  //      g = g > 255 ? 255 : g;
  //      break;
  //    case 'G':
  //      g -= d;
  //      g = g < 0 ? 0 : g;
  //      break;
  //    case 'b':
  //      b += d;
  //      b = b > 255 ? 255 : b;
  //      break;
  //    case 'B':
  //      b -= d;
  //      b = b < 0 ? 0 : b;
  //      break;
  //    case 'd':
  //      d = d * 2;
  //      d = d > 64 ? 64 : d;
  //      break;
  //    case 'D':
  //      d = d / 2;
  //      d = d < 2 ? 1 : d;
  //      break;
  //    case ']':
  //      ++presetIndex;
  //      if (presetIndex > presets.length - 1)
  //        presetIndex = 0;
  //      current = presets[presetIndex];
  //      r = current >> 16 & 0xFF;
  //      g = current >> 8 & 0xFF;
  //      b = current & 0xFF;
  //      break;
  //    case '[':
  //      --presetIndex;
  //      if (presetIndex < 0)
  //        presetIndex = presets.length - 1;
  //      current = presets[presetIndex];
  //      r = current >> 16 & 0xFF;
  //      g = current >> 8 & 0xFF;
  //      b = current & 0xFF;
  //      break;
  //  }
  //  current = color(r, g, b);
  //}
  
  //public void drawPresetColors(int y) {
  //  int w = 20;
  //  for (int i = 0; i < presets.length; ++i) {
  //    color c = presets[i];
  //    fill(c);
  //    noStroke();
  //    if (i == presetIndex) {
  //      stroke(0);
  //      strokeWeight(1.5f);
  //    }
  //    rect(10 + w * i, y, w, 15);
  //    fill(0);
  //  }
  //}