from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput


class TestApp(App):

    def build(self):
        self.status_label = Label(text='')
        self.send_button = Button(text='Send')
        self.amount_input = TextInput(multiline=False)
        self.name_input = TextInput(multiline=False)
        self.send_button.bind(on_press=self.send)

        screen = BoxLayout(orientation='vertical')
        screen.add_widget(Label(text='Name'))
        screen.add_widget(self.name_input)
        screen.add_widget(Label(text='Amount'))
        screen.add_widget(self.amount_input)
        screen.add_widget(self.send_button)
        screen.add_widget(self.status_label)
        return screen

    def send(self, pos):
        self.status_label.text = '%s, %s' % (self.name_input.text, self.amount_input.text)

TestApp().run()