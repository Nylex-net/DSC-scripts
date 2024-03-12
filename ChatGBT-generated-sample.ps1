Configuration MyServerConfig {
    Node 'MyServer' {
        WindowsFeature WebServerFeature {
            Ensure = 'Present'
            Name = 'Web-Server'
        }
    }
}

MyServerConfig -OutputPath 'C:\DSC\' -Verbose