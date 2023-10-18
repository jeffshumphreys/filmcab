#ifndef SHAREDENUMERATIONS_H
#define SHAREDENUMERATIONS_H

#include <QFlags> // Necessary for it to recognize FileChangeDetectionS
#include <QString>
#include <QVariant>
#include "qobjectdefs.h"
//#include "qtmetamacros.h" // Necessary for the Q_ENUM

// These are aligned with items in public.typs. WARNING: if they change, this could seriously corrupt the files table.

enum CommonFileTypes {
    file           = 7, // Our default when caller to ProcessFilesTask.run() doesn't pass a type, defaulting to 0.
    torrent_file   = 8, // In the D:\qBittorrent Downloads\_torrent files directory, ending ".torrent" Need to expand my extension field
    published_file = 9, // These get renamed alot, and I move them into different categories (directories) fairly often.
    backedup_file = 10, // Should be really still
    directory     = 12
}; // Not all of them, just as I use them.

enum PreProcessTable { truncate, // Not really ready for this, makes sense in stage_for_master, receiving and shipping dock, not master.
                       leave_as_is,
                       delete_data
};

enum AddRowsMethod {
    update_data_if_logical_key_collision, ignore_if_logical_key_collision, replace_if_logical_key_collision, skip_if_logical_key_collision, error_if_logical_key_collision
};

enum IdentityMethod {
    reset_if_truncating, do_not_reset, no_sequence_set_max_plus_1 /* For small lookup tables */
};

enum LoopProcessingExitCommands {
    stop_no_error,
    system_database_different_error,
    no_op, // Nothing done
    completed
};

// Another mess!  But I want these related all to each other. if mod_dt newer the n scan or do something else.

class FileChangeDetectionClass {
public:
    enum FileChangeDetection {
        check_hash                                        = 0x1,
        check_dir_mod_dt_against_directory_recrded_mod_dt = 0x2,
        scan_dir_if_mod_dt_newer                          = 0x4,
        recalc_hash                                       = 0x8
        };
    Q_DECLARE_FLAGS(FileChangeDetections, FileChangeDetection)
};
Q_DECLARE_OPERATORS_FOR_FLAGS(FileChangeDetectionClass::FileChangeDetections)

#endif // SHAREDENUMERATIONS_H
