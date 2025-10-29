/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/hero-06.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Hero06({ alt, ...rest }: Props) {
  return <img src={String(src)} alt={alt ?? 'Hero 06'} loading="lazy" decoding="async" {...rest} />;
}
