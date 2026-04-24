public class MacFactory implements GUIFactory {
	public Button createButton(){
		return new MacButton();
	}
	public Window createWindow(){
		return new MacWindow();
	}
}
