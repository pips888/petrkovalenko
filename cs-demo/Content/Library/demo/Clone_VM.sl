namespace: demo
flow:
  name: Clone_VM
  inputs:
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuidAHA: '${"pkov-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuidAHA}'
            - end_index: '13'
        publish:
          - new_UUID: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: 10.0.46.10
              - user: "Capa1\\1107-capa1user"
              - password:
                  value: Automation123
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: Ubuntu
              - datacenter: Capa1 Datacenter
              - vm_name: '${prefix+new_UUID}'
              - vm_folder: Students/Kovalenko
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - return_result
          - vm_id
          - host
          - user
          - password
          - datacenter
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${user}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+new_UUID}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      substring:
        x: 253
        y: 69
      uuid:
        x: 96
        y: 150
      clone_vm:
        x: 416
        y: 54
      power_on_vm:
        x: 383
        y: 231
        navigate:
          2e21d6b5-cb1e-04b9-6c6f-f358bca6136b:
            targetId: db685643-1642-dd46-f843-af448ed38a02
            port: SUCCESS
    results:
      SUCCESS:
        db685643-1642-dd46-f843-af448ed38a02:
          x: 579
          y: 186
