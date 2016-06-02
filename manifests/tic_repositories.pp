# private repos
class syncope::tic_repositories($access_token=undef) {
  include ::packagecloud

  packagecloud::repo {'talend/other':
    type         => 'rpm',
    master_token => $access_token
  }

}

