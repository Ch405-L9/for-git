/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/features-02.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Features02({ alt, ...rest }: Props) {
  return (
    <img src={String(src)} alt={alt ?? 'Features 02'} loading="lazy" decoding="async" {...rest} />
  );
}
