class EmptyTarget
  def save!
    false
  end

  def self.message
    msg = "Sorry command not recognized. \n\n"
    msg << "Try following \n\n"
    msg << "*{amount} to {name}*\n"
    msg << "_to register an outgoing transaction._\n\n"
    msg << "*{amount} from {name}*\n"
    msg << "_to register an incoming transaction._\n\n"
    msg << "*daily report*\n"
    msg << "_to get daily incoming and outgoing summary._\n\n"
    msg << "*weekly report*\n"
    msg << "_to get weekly incoming and outgoing summary._\n\n"
    msg << "*help*\n"
    msg << "_to get this description._\n\n"
  end

end