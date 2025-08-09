from abc import ABC, abstractmethod
from typing import Literal


UP, RIGHT, LEFT, DOWN = '^', '>', '<', 'v'
class Keypad(ABC):
    @abstractmethod
    def __init__(self):
        self.grid = []
        self.pos = []
        self.history = []

    def press(self):
        value = self.grid[self.pos[0]][self.pos[1]]
        self.history.append(value)
        return value

    def move(self, dir: Literal['<', 'v', '^', '>']):
        if dir == LEFT:
            self.pos[1] -= 1
        elif dir == RIGHT:
            self.pos[1] += 1
        elif dir == UP:
            self.pos[0] -= 1
        elif dir == DOWN:
            self.pos[0] += 1

class NumericKeypad(Keypad):
    def __init__(self):
        self.grid = [['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], ['x', '0', 'A']]
        self.pos = [3, 2]
        self.history = []

class DirectionalKeypad(Keypad):
    def __init__(self):
        self.grid = [['x', UP, 'A'], [LEFT, DOWN, RIGHT]]
        self.pos = [0, 2]
        self.history = []

class Decoder:
    def __init__(self, input: str):
        self.input = input
        self.keypads = [NumericKeypad(), DirectionalKeypad(), DirectionalKeypad()]

    def decode(self):
        for c in self.input:
            idx = 2
            pressed = c
            while idx >= 0 and pressed == 'A':
                pressed = self.keypads[idx].press()
                idx -= 1
            
            self.keypads[idx].move(pressed)

        for i, kp in enumerate(self.keypads):
            print(f'Layer {i+1}: {kp.history}')

print('Ours:')
d = Decoder('v<<A>>^AAvA^Av<A<AA>>^AAvA<^A>AvA^Av<A<A>>^AAvA^Av<<A>>^AvA<^A>Av<A>^A<A>A')
d.decode()
