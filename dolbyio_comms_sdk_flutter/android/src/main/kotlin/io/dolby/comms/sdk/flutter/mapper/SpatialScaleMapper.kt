package io.dolby.comms.sdk.flutter.mapper

import com.voxeet.android.media.spatialisation.SpatialScale

class SpatialScaleMapper {
    companion object {
        fun fromMap(map: Map<String, Any?>?): SpatialScale? {
            if (map == null || !map.contains("x") || !map.contains("y") || !map.contains("z"))
                return null
            return SpatialScale(map["x"] as Double, map["y"] as Double, map["z"] as Double)
        }
    }
}
