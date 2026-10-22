#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

#include "camera/winter_camera_rig.hpp"

using namespace godot;

static void initialize_wintertd(ModuleInitializationLevel level) {
    if (level == MODULE_INITIALIZATION_LEVEL_SCENE) {
        ClassDB::register_class<WinterCameraRig>();
    }
}

static void uninitialize_wintertd(ModuleInitializationLevel level) {
    (void)level;
}

extern "C" {
GDExtensionBool GDE_EXPORT wintertd_library_init(
    GDExtensionInterfaceGetProcAddress get_proc_address,
    GDExtensionClassLibraryPtr library,
    GDExtensionInitialization *initialization) {
    GDExtensionBinding::InitObject init(get_proc_address, library, initialization);
    init.register_initializer(initialize_wintertd);
    init.register_terminator(uninitialize_wintertd);
    init.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
    return init.init();
}
}
