node 'server5', 'server6', 'server7', 'server11', 'server12', 'server15', 'server19', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6', 'filter7', 'filter8', 'filter9', 'filter10', 'filter11', 'filter12', 'filter13', 'filter14', 'filter15', 'filter16', 'filter17', 'filter18', 'notification1', 'notification2' {
  include statsclient

  class {'filterserver':
    is_default => true
  }

  class {'notificationserver':
    is_default => false
  }

}
