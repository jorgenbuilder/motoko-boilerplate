import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

import Canistergeek "mo:canistergeek/canistergeek";

import Admins "Admins";

shared ({ caller = creator }) actor class MotokoBoilerplate () {


    ///////////////////
    // Stable State //
    /////////////////

    // Canister admins
    private stable var s_admins = [creator];

    // Canistergeek
    private stable var s_canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    private stable var s_canistergeekLoggerUD: ? Canistergeek.LoggerUpgradeData = null;

    // Heartbeat
    private stable var s_heartbeatIntervalSeconds : Nat = 30;
    private stable var s_heartbeatLastBeat : Int = 0;


    ///////////////
    // Upgrades //
    /////////////


    system func preupgrade() {
        // Preserve canistergeek
        s_canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();
        s_canistergeekLoggerUD := ? canistergeekLogger.preupgrade();

        // Preserve admins
        s_admins := _Admins.backup();
    };

    system func postupgrade() {
        // Process canistergeek
        canistergeekMonitor.postupgrade(s_canistergeekMonitorUD);
        s_canistergeekMonitorUD := null;
        canistergeekLogger.postupgrade(s_canistergeekLoggerUD);
        s_canistergeekLoggerUD := null;
    };

    /// Basic healthcheck method.
    public query func ping () : async Text {
        "pong";
    };


    ////////////////
    // Heartbeat //
    //////////////
    // IC blockchain native cron.


    // Simply declaring this system function will increase cycle costs very, very significantly.
    // system func heartbeat () : async () {};


    ///////////////////
    // Canistergeek //
    /////////////////
    // Tracks memory and cycle usage, provides logging


    // Metrics

    private let canistergeekMonitor = Canistergeek.Monitor();

    /// Returns collected data based on passed parameters. Called from browser.
    public query ({ caller }) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        assert(_Admins._isAdmin(caller));
        canistergeekMonitor.getMetrics(parameters);
    };

    /// Force collecting the data at current time. Called from browser or any canister "update" method.
    public shared ({ caller }) func collectCanisterMetrics(): async () {
        assert(_Admins._isAdmin(caller));
        _log(caller, "collectCanisterMetrics", "ADMIN :: Forcing canister metrics collection");
        canistergeekMonitor.collectMetrics();
    };

    /// This needs to be place in every update call. Captures canister metrics
    private func _captureMetrics () : () {
        canistergeekMonitor.collectMetrics();
    };

    // Logging

    private let canistergeekLogger = Canistergeek.Logger();

    /// Returns collected log messages based on passed parameters. Called from browser.
    public query ({ caller }) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
        assert(_Admins._isAdmin(caller));
        canistergeekLogger.getLog(request);
    };

    /// Push a message to canister logs.
    private func _log (
        caller  : Principal,
        method  : Text,
        message : Text,
    ) : () {
        let out : Text = Principal.toText(caller) # " :: " # method # " :: " # message;
        Debug.print(out);
        canistergeekLogger.logMessage(out);
    };


    /////////////////////
    // Access Control //
    ///////////////////
    // Allows us to manage access to canister methods
    

    let _Admins = Admins.Factory({
        s_admins;
        _log;
    });

    public shared ({ caller }) func addAdmin (
        p : Principal,
    ) : async () {
        _captureMetrics();
        _Admins.addAdmin(caller, p);
    };

    public query ({ caller }) func isAdmin (
        p : Principal,
    ) : async Bool {
        _Admins.isAdmin(caller, p);
    };

    public shared ({ caller }) func removeAdmin (
        p : Principal,
    ) : async () {
        _captureMetrics();
        _Admins.removeAdmin(caller, p);
    };

    public query func getAdmins () : async [Principal] {
        _Admins.getAdmins();
    };

};