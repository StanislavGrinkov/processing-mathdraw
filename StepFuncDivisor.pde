class StepFuncDivisor extends StepFuncBase {
  
  public StepFuncDivisor(float init, float min, float max, float step) {
    super(init, min, max, step);
  }
  
  @Override
  public float next(float v) {
    return v / value;
  }
  
  @Override
  public String description() {
    return "Non linear step function h = h / divisor.";
  }
  
  @Override
  public StepFuncBase clone() {
    return new StepFuncDivisor(this.value, this.min, this.max, this.step);
  }
}