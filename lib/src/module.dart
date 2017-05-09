// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Associates types with their concrete instances returned by the [Injector]
abstract class Module {
    final Logger _logger = new Logger('dice.Module');

    ///  register a [type] with [named] (optional) to an implementation
    Registration register(Type type, { final String named: null, final Type annotatedWidth: null }) {
        final registration = new Registration(type);
        final typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, named, annotatedWidth);

        _logger.fine("Register: ${typeMirrorWrapper.qualifiedName}");
        _registrations[typeMirrorWrapper] = registration;
        return registration;
    }

    /// Configure type/instance registrations used in this module
    configure();

    /// Copies all bindings of [module] into this one.
    /// Overwriting when conflicts are found.
    void install(final Module module) {
        module.configure();
        _registrations.addAll(module._registrations);
    }

    bool _hasRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations.containsKey(new TypeMirrorWrapper(type, name, annotation));

    Registration _getRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations[new TypeMirrorWrapper(type, name, annotation)];

    final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();
}

/// Combines several [Module] into single one, allowing to inject
/// a class from one module into a class from another module.
class _ModuleContainer extends Module {
    _ModuleContainer(List<Module> this._modules);

    @override
    configure() {
        _modules.fold(_registrations, (acc, module) {
            module.configure();
            return acc..addAll(module._registrations);
        });
    }

    List<Module> _modules;
}
