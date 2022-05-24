/// Provides administrative access control and administrator management.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";


module Admins {


    //////////////
    // Factory //
    ////////////


    public class Factory (state : State) : Interface {

        /// There must be at least one admin at initialization.
        assert(state.s_admins.size() != 0);


        ////////////
        // State //
        //////////


        /// The list of administrators of this canister.
        private var admins : Buffer.Buffer<Principal> = Buffer.Buffer(0);

        /// Returns all state of the admin module.
        public func backup () : [Principal] {
            admins.toArray();
        };

        /// Restores state of admin module from backup.
        public func restore (
            backup : StableState,
        ) : () {
            for (admin in state.s_admins.vals()) {
                admins.add(admin);
            };
        };

        restore(state);


        //////////
        // API //
        ////////


        /// Use this to add an admin-only restriction.
        /// ex: assert(_isAdmin(caller));
        public func _isAdmin(p : Principal) : Bool {
            for (a in admins.vals()) {
                if (a == p) { return true; };
            };
            false;
        };

        /// Adds a new principal as an admin.
        public func addAdmin(caller : Principal, p : Principal) : () {
            assert(_isAdmin(caller));
            state._log(caller, "addAdmin", "ADMIN :: Adding admin " # Principal.toText(p));
            admins.add(p);
        };

        /// Removes the given principal from the list of admins.
        public func removeAdmin(caller : Principal, p : Principal) : () {
            assert(_isAdmin(caller));
            state._log(caller, "removeAdmin", "ADMIN :: Removing admin " # Principal.toText(p));
            let newAdmins = Array.filter(
                admins.toArray(),
                func (a : Principal) : Bool {
                    a != p;
                },
            );
            admins.clear();
            for (admin in newAdmins.vals()) {
                admins.add(admin);
            };
        };

        /// Check whether the given principal is an admin.
        public func isAdmin(caller : Principal, p : Principal) : Bool {
            for (a in admins.vals()) {
                if (a == p) return true;
            };
            return false;
        };

        /// Return a list of all admins.
        public func getAdmins() : [Principal] {
            admins.toArray();
        };
    };


    ////////////
    // Types //
    //////////

    /// Stable state utilized by this module.
    public type StableState = {
        s_admins  : [Principal];
    };

    /// External state and functions utilized by this module.
    public type Dependencies = {
        _log : (caller  : Principal, method  : Text, message : Text) -> ();
    };

    /// Total state utilized by this module.
    public type State = StableState and Dependencies;

    public type Interface = {
        // Use this to add an admin-only restriction.
        // @modifier
        _isAdmin : (p : Principal) -> Bool;

        /// Adds a new principal as an admin.
        addAdmin : (caller : Principal, p : Principal) -> ();

        /// Removes the given principal from the list of admins.
        removeAdmin : (caller : Principal, p : Principal) -> ();
        
        /// Checks whether the given principal is an admin.
        isAdmin : (caller : Principal, p : Principal) -> Bool;
    };

};