class private::users {
  users::user {'test':
    password => '$6$k.fe9F4U$OIav.SJZuujVfXk4HTKS.i94ZuQtoJNCH6KH1ePar57yc3y51G0PbGPXT6zO5v.q3h5TM87MDx0QEX4TTENq.0',
    authorized_keys => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLrPR2CZLSs6tKSEUBeaahzcKhWwQAN9Hwcrn5HpS0FTz3VFbyJXNP5KZYci3zF6/CHNSM1iOkV6t/6U8g16+PWOo5pMNg7jWqoZD6ukT+cX6ZuNm8CtIx7EzwFxGB8INrKAonmpG9FRWHMppi4nJG5SrQv2rgoUDt+Dbu2oPMh/EGUS2wQ7VUwA1/qAeRsAdptrGB6wr/+1fGTdrZy11AG+sLnrO+VXIShOFCuv9czbj9nw5Bi6jwnWrzvfQx1BfwVwYtdfGSprB6p+8aL7u3SCF+aJAGGRoYjqec4+EM5xRJ3grmoFtkngEiJIaLWRPkgD8uggY2spmff1Ypl24v test@test',
    sudo => true
  }
}
