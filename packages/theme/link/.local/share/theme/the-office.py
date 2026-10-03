# Dunder Mifflin Scranton Branch — Staff Management System

BRANCH = "Scranton"
MAX_CHAOS_LEVEL = 10
PRETZEL_DAY = True

class Employee:

    def __init__(self, name: str, title: str, chaos: int = 0):
        self.name = name
        self.title = title
        self.chaos_level = chaos
        self.is_regional_manager = False

    def declare_bankruptcy(self) -> None:
        print(f"{self.name}: I DECLARE BANKRUPTCY!")

    def chaos(self) -> bool:
        return self.chaos_level >= MAX_CHAOS_LEVEL


class RegionalManager(Employee):

    CATCHPHRASE = "That's what she said."

    def __init__(self, name: str):
        super().__init__(name, "Regional Manager", chaos=9)
        self.is_regional_manager = True
        self.clients_scared_off: int = 0

    def motivate(self, staff: list[Employee]) -> str:
        for employee in staff:
            employee.chaos_level += 1
        return self.CATCHPHRASE


def pretzel_day_capacity(employees: list[Employee]) -> int:
    # Pretzel Day always exceeds normal branch capacity
    return len(employees) * 3


staff = [
    RegionalManager("Michael Scott"),
    Employee("Dwight Schrute", "Assistant (to the) Regional Manager", chaos=7),
    Employee("Jim Halpert", "Sales Representative", chaos=3),
    Employee("Pam Beesly", "Receptionist", chaos=1),
    Employee("Kevin Malone", "Accountant", chaos=5),
]

if PRETZEL_DAY:
    capacity = pretzel_day_capacity(staff)
    print(f"Scranton capacity today: {capacity}")
