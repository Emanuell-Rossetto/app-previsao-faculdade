class CityModel {
  int? id;
  String? nome;
  Microrregiao? microrregiao;
  RegiaoImediata? regiaoImediata;

  CityModel({this.id, this.nome, this.microrregiao, this.regiaoImediata});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    microrregiao = json['microrregiao'] != null
        ? Microrregiao.fromJson(json['microrregiao'])
        : null;
    regiaoImediata = json['regiao-imediata'] != null
        ? RegiaoImediata.fromJson(json['regiao-imediata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    if (microrregiao != null) {
      data['microrregiao'] = microrregiao!.toJson();
    }
    if (regiaoImediata != null) {
      data['regiao-imediata'] = regiaoImediata!.toJson();
    }
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Microrregiao {
  int? id;
  String? nome;
  Mesorregiao? mesorregiao;

  Microrregiao({this.id, this.nome, this.mesorregiao});

  Microrregiao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    mesorregiao = json['mesorregiao'] != null
        ? Mesorregiao.fromJson(json['mesorregiao'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    if (mesorregiao != null) {
      data['mesorregiao'] = mesorregiao!.toJson();
    }
    return data;
  }
}

class Mesorregiao {
  int? id;
  String? nome;
  UF? uF;

  Mesorregiao({this.id, this.nome, this.uF});

  Mesorregiao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    uF = json['UF'] != null ? UF.fromJson(json['UF']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    if (uF != null) {
      data['UF'] = uF!.toJson();
    }
    return data;
  }
}

class UF {
  int? id;
  String? sigla;
  String? nome;
  Regiao? regiao;

  UF({this.id, this.sigla, this.nome, this.regiao});

  UF.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sigla = json['sigla'];
    nome = json['nome'];
    regiao = json['regiao'] != null ? Regiao.fromJson(json['regiao']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sigla'] = sigla;
    data['nome'] = nome;
    if (regiao != null) {
      data['regiao'] = regiao!.toJson();
    }
    return data;
  }
}

class Regiao {
  int? id;
  String? sigla;
  String? nome;

  Regiao({this.id, this.sigla, this.nome});

  Regiao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sigla = json['sigla'];
    nome = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sigla'] = sigla;
    data['nome'] = nome;
    return data;
  }
}

class RegiaoImediata {
  int? id;
  String? nome;
  Mesorregiao? regiaoIntermediaria;

  RegiaoImediata({this.id, this.nome, this.regiaoIntermediaria});

  RegiaoImediata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    regiaoIntermediaria = json['regiao-intermediaria'] != null
        ? Mesorregiao.fromJson(json['regiao-intermediaria'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    if (regiaoIntermediaria != null) {
      data['regiao-intermediaria'] = regiaoIntermediaria!.toJson();
    }
    return data;
  }
}
