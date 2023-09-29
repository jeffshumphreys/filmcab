#ifndef SHAREDENUMERATIONS_H
#define SHAREDENUMERATIONS_H

// These are aligned with items in public.types

enum CommonFileTypes { file = 7, torrent_file = 8, published_file = 9, backedup_file = 10}; // Not all of them, just as I use them.
enum TargetLayer { stage_for_master, master }; // Only two so far.
enum PreProcessTable { truncate, leave_as_is, delete_data };
enum AddMethod { update_data_if_logical_key_collision, ignore_if_logical_key_collision, replace_if_logical_key_collision, skip_if_logical_key_collision, error_if_logical_key_collision };
enum IdentityMethod { reset_if_truncating, do_not_reset, no_sequence_set_max_plus_1 /* For small lookup tables */ };

#endif // SHAREDENUMERATIONS_H
