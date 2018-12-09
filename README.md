## MyFS
Dieses Repository ist eine Erweiterung der Betriebssysteme Übung um eine Docker Umgebung.
Die folgenden Beschreibungen von Docker lassen bewusst vieles aus und sind weitestgehend auf das Labor maßgeschneidert.
Docker ist sehr vielfältig; ein typisches Docker Training durch einen Experten nimmt zwei volle Tage in Anspruch.

Der Installer von Docker ist ca. 500MB groß.
Die benötigten Images/Pakete des gebauten Docker Images benötigen weitere 100MB.

### Was ist Docker?
Docker ist eine Software zur Realisierung von Containervirtualisierung. Container sind im Grunde sehr leichtgewichtige VMs. Docker Images enthalten lauffähige Applikationen mit allen notwendigen Abhängigkeiten.
Für die Entwicklung empfiehlt es sich einen Container zustandslos (stateless) zu halten, um einen deterministischen Zustand zu erreichen.
Docker Container haben verschiedene sog. Lifecylce Zustände. Genaueres können Sie hier lesen:
https://medium.com/@nagarwal/lifecycle-of-docker-container-d2da9f85959
Beim Starten erhält jeder Container eine eindeutige zufällige HEX id z.B. 0ff43e33f9d8.
Da dies recht unhandlich ist können Sie beim Start eines Containers (docker run) einen Namen setzen z.B. '--name myCon'.
In nahezu allen Docker Befehlen, die eine Container id erwarten können Sie stattdessen den gesetzten Namen des Containers angeben.

### Was ist ein Docker Image?
Ein Docker Image ist eine Art Snapshot eines zu startenden Containers, der auf jedem Host gestartet werden kann, auf dem Docker installiert ist.
Das Image liegt in Form von einer Datei vor und kann mit einem einfachen 'docker run' Befehl innerhalb weniger Sekunden gestartet werden.
So wie sie für Docker Container Namen vergeben können, können sie ein Docker Image mit einem oder mehreren Tags versehen (docker tag).

### Was tut das Dockerfile?
Die sauberste Möglichkeit, um ein eigenes Docker Image zu erstellen ist das Dockerfile. Ein Dockerfile beschreibt die zur Bereitstellung eines Containers notwendigen Schritte in Form von Code; es ist ein Bauplan für das Docker Image.
Dockerfiles bauen immer auf einem Basis-Image auf, z.B. Alpine oder Ubuntu. Mithilfe des 'docker build' Befehls lässt sich aus einem Dockerfile ein Docker Image bauen.
Das hier geschriebene Dockerfile beschreibt einen auf Ubuntu 16.04 aufbauenden Container (FROM) in dem alle für Fuse notwendigen Pakete mit Befehlen (RUN) installiert werden.
Für alle wichtigen verwendeten Pakete und Base-Images sollten die Versionen stets mit angegeben werden um böse Überraschungen (Breaking Changes) bei Paket-Updates zu vermeiden. Anschließend werden alle notwendigen vorgegebenen Projektdateien in den Container hineinkopiert (COPY).
Beim Start des Containers wird standardmäßig das Projekt über ein Makefile gebaut und die Unittests ausgeführt.

### Wie installiere ich Docker?
Achten Sie darauf die Community Edition von Docker zu installieren, nicht die Enterprise Edition!

#### Windows 10

Wenn Sie definitiv wissen, dass Sie keine virtuellen Maschinen(VMware/Virtualbox) zusätzlich benötigen,
sollten Sie direkt docker-for-windows anstelle der Docker-Toolbox installieren.
Vorteile sind hohe Performance und keinerlei Kapriolen bezüglich der bei der Docker-Toolbox zugrunde liegenden Virtualbox VM.

Öffnen Sie die Powershell mit Administratorrechten.
Mit folgenden Befehlen installieren Sie Chocolatey (Windows Paket Manager) und anschließend das docker-toolbox (bzw. docker-for-windows) Chocolatey Paket.
```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

Installieren Sie nur EINES von beiden Paketen, diese stören sich nämlich gegenseitig:

Docker-Toolbox:
```
choco install docker-toolbox
```
Docker for Windows:
```
choco install docker-for-windows
```

#### Linux
Auf https://get.docker.com/ findet sich ein generisches Shell Script mit dem sich Docker auf einem beliebigen Linux installieren lässt.
Mit folgenden Befehlen laden Sie das Script herunter und führen es aus.
```
curl https://get.docker.com/ -o install.sh

sh install.sh
```
oder mit dem Paket Manager Ihres Linux Systems (apt/aptitude/apk/yum)
```
apt update && apt install docker.io
```

#### MacOS
```
brew cask install docker
```

#### Manuell
Laden Sie den passenden Installer herunter und installieren Sie die Docker Toolbox:
https://docs.docker.com/toolbox/overview/#whats-in-the-box
Starten Sie anschließend das soeben mitinstallierte "Docker Quickstart Terminal".

### Quickstart
Es steht ein kleines Shell Script bereit (executeTests.sh).
Dieses baut beim Ausführen das Docker Image und startet es.
Beachten Sie, dass das Script aus seinem Quellverzeichnis (also diesem Repository) heraus ausgeführt werden muss,
da es relative Pfadangaben enthält.
Sämtliche Docker-spezifischen Ausgaben beim Bauen des Images werden unterdrückt,
sodass lediglich die Ausgaben des Docker Containers angezeigt werden.
Wenn Sie die Ausgaben sehen möchten, starten Sie das Script mit dem -v Flag:
sh executeTests.sh -v

Für weitere Informationen führen Sie das Script mit dem Help Flag (-h) aus oder schauen Sie hinein.

#Layer im Dockerfile
Docker baut aus jedem Befehl im Dockerfile (FROM, RUN, COPY, ...) je ein Layer, d.h. ein Zwischen-Image.
Diese Layer werden nacheinander übereinander geschichtet und bilden das finale Image.
Beim erneuten Bauen des unveränderten Dockerfiles können sämtliche unveränderten Layer gecachet werden.
Das erste Bauen dauert somit am längsten, danach geht es sehr schnell.
Wird ein Befehl im Dockerfile jedoch verändert, so muss dieser Layer sowie alle Layer (Befehle) darunter neu gebaut werden.
Es empfiehlt sich daher statische bzw. selten veränderte Befehle möglichst weit nach oben im Dockerfile zu verschieben.

### Debugger für einen Docker Container benutzen
Das Debuggen des Containers zur Laufzeit ist mittels Remote Debugging möglich.
Hierzu benötigen Sie einen offenen TCP Port zum Container, z.B. 5005.
Ports vom Container können sie gegenüber dem Host öffnen, indem Sie beim Starten mittels 'docker run' je ein p Flag angeben.
Beachten Sie, dass sie die Ports des Containers auf Ports des Hosts mappen müssen.
Beispiel: 'docker run -d -p 443:80 nginx'
startet einen Docker Container mit nginx im Hintergrund (-d) und gibt den im Container genutzten Port 80 auf dem Host als Port 443 frei.
Die Konfiguration des Remote Debuggings ist IDE und Debugger spezifisch.
Einige exemplarische Anleitungen finden Sie hier:
IntelliJ:
https://medium.com/beyond/running-a-play-app-with-docker-locally-and-debugging-with-intellij-idea-746eaf1732da
Eclipse:
https://sdqweb.ipd.kit.edu/wiki/Remote_Debugging_mit_Eclipse

### FAQ
#### Wie komme ich mit dem Terminal in den Docker Container (z.B. für manuelles Testen)?
Interaktives Starten eines neuen Containers:
```
docker run --rm -it test-image sh
```
Interaktiv Verbinden auf einen laufenden Container:
```
docker exec -it test-container sh
```

#### Wie kopiere ich Dateien zwischen Docker Container und Host?
Quell- und Zielpfad sind im folgenden absolut angegeben.
Der Pfad des Hosts könnte auch relativ angegeben werden.
Ähnlich wie beim normalen cp Befehl können Sie hinter dem Zielpfad einen anderen Namen,
als den der Quelldatei wählen, um die Kopie umzubennen.

Host --> Container
```
docker cp /tmp/example.txt mycontainer:/root/example.txt


```

Container --> Host
```
docker cp mycontainer:/root/example.txt /tmp/example.txt
```

#### Wie finde ich über das Terminal heraus welches Linux Betriebssystem ich habe?
```
cat /etc/*release
```
#### Warum sollte ich auf Windows die Docker-Toolbox und nicht einfach Docker for Windows installieren?
##### kurze Erklärung:
Auf Windows können Sie nach der Installation von Docker (Docker for Windows) keine typischen virtuellen Maschinen mehr starten (VMware/Virtualbox/...).

##### ausführliche Erklärung:
Docker setzt auf dem Linux Kernel auf.
Linux und MacOS bauen ebenfalls darauf auf, somit ist dessen Nutzung durch Docker kein Problem.
Auf Windows steht kein Linux Kernel zur Verfügung, daher muss eine Virtualisierungslösung hier Abhilfe schaffen.
Virtuelle Maschinen nutzen auf unterster Ebene die über einen Hypervisor bereitgestellten Ressourcen des Hosts, auf dem sie laufen. Für Windows existiert die Software Docker for Windows. Diese nutzt einen eigenen Hypervisor (Hyper-V), der die Ressourcen des Hosts belegt und damit für andere Hypervisors (Virtualbox/VMware) unbenutzbar macht.
Sie können jedoch theoretisch auch VMs über den Hyper-V managen lassen. Für die meisten Linux-typischen Use Cases reicht aber bereits das Linux Subsystem von Windows 10 aus. Falls Sie allerdings auf bestehende virtuelle Maschinen (Virtualbox/VMware) angewiesen sind, empfiehlt es sich anstelle von Docker die Docker-Toolbox zu installieren.

#### Wie funktioniert die Docker-Toolbox?
Die Docker-Toolbox stellt die zwei Komponenten von Docker bereit: Docker Daemon und Docker CLI.
Die CLI ist die bloße Kommandozeilenanwendung, der Docker Daemon ist die Kernkomponente von Docker, die auf dem Linuxkernel aufsetzt. Docker-Toolbox startet hierfür eine virtuelle Maschine mit Virtualbox, auf der der Docker Daemon läuft.
Beachten Sie, dass Docker Container innerhalb der Virtualbox VM keine Ports auf localhost mappen können. Standardmäßig hat diese VM die IP 192.168.99.100

#### Was ist Chocolatey?
Chocolatey ist ein ThirdParty Paketmanager für Windows. Er wird seit 2015 offiziell durch die Windows Powershell Package Management Funktionen unterstützt.
Diese Integrationen sind jedoch recht unhandlich und unintuitiv, sodass sich die direkte Verwendung des choco Commands empfiehlt.
Beachten Sie, dass Chocolatey nur Pakete "tracken" kann, die mit Chocolatey installiert (und ggf auch wieder deinstalliert) wurden.
Die Community Version von Chocolatey ist auf die Installation in die vom jeweiligen Paket festgelegten Standardverzeichnisse beschränkt.

Die wichtigsten Chocolatey Befehle:
Alle mit Chocolatey installierten Pakete anzeigen:
```
choco list -la
```
Installiere ein Paket ohne Rückfragen (Beispiel Firefox)
```
choco install firefox -y
```
Deinstalliere ein Paket mit Rückfragen (Beispiel Firefox)
```
choco uninstall firefox
```



#### could not read CA certificate "C:\\Users\\Hacker\\.docker\\machine\\machines\\default\\ca.pem": open C:\Users\Hacker\.docker\machine\machines\default\ca.pem: Das System kann den angegebenen Pfad nicht finden.
Die Docker-Toolbox setzt Umgebungsvariablen, die die Ausführung anderer Docker Varianten beeinträchtigen.
Mit folgenden Powershell Befehlen können Sie die störenden Umgebungsvariablen löschen:
```
[Environment]::SetEnvironmentVariable("DOCKER_CERT_PATH", $null, "User")
[Environment]::SetEnvironmentVariable("DOCKER_HOST", $null, "User")
[Environment]::SetEnvironmentVariable("DOCKER_MACHINE_NAME", $null, "User")
[Environment]::SetEnvironmentVariable("DOCKER_TLS_VERIFY", $null, "User")
[Environment]::SetEnvironmentVariable("DOCKER_TOOLBOX_INSTALL_PATH", $null, "User")
```

#### Wie räume ich den durch Docker Container und Images belegten Speicher wieder frei?
Mit dem Befehl 'docker rm' können Sie einen spezifischen Container löschen, sofern dieser nicht mehr läuft.
Stoppen können Sie den Container mit 'docker stop'.
Mit dem Befehl 'docker rmi' können Sie ein spezifisches Docker Image löschen, sofern dieses nicht von einem bestehenden Container verwendet wird.

Eine bequeme Möglichkeit um viele Container und Images auf einmal zu löschen ist der Befehl 'docker system prune'.

#### Ich möchte Docker auf Windows7 oder älter installieren
Dies wird offiziell nicht unterstützt, ist aber prinzipiell mit Chocolatey möglich.
Bezüglich der Konfiguration, um Docker nutzbar zu machen, sollten Sie sich allerdings auf ein Abenteuer gefasst machen.
