class StepFuncEqualStep extends StepFuncBase {
  
  public StepFuncEqualStep(float init, float min, float max, float step) {
    super(init, min, max, step);
  }
  
  @Override
  public float next(float v) {
    return v - value;
  }
  
  @Override
  public String description() {
    return "Simple linear step function: h = h - step.";
  }
  
  @Override
  public StepFuncBase clone() {
    return new StepFuncEqualStep(this.value, this.min, this.max, this.step);
  }
}