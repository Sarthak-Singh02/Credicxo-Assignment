//These states will be emitted on particular event
abstract class InternetState{}

class InternetInitialState extends InternetState{}
class InternetLostState extends InternetState{}
class InternetGainedState extends InternetState{}